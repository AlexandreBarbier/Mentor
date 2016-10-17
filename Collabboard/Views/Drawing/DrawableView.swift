//
//  DrawableView.swift
//  Mentor
//
//  Created by Alexandre on 11/10/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit
import CloudKit
import FirebaseDatabase
import ABUIKit

// TODO: manage multi size screen (simple solution : create a view with the max screen size)
/// this is the view used to draw everything
class DrawableView: UIView, UIGestureRecognizerDelegate {
    fileprivate var markerAlpha : CGFloat = 0.4
    fileprivate var layerIndex = 0
    fileprivate var path = UIBezierPath()
    fileprivate var history = [(layer:CALayer,dPath:DrawingPath)]()
    fileprivate var historyIndex = 0
    fileprivate var interPolationPoints = [CGPoint] ()
    fileprivate var touchCircle = UIBezierPath()
    fileprivate var red : CGFloat = 0.0
    fileprivate var green : CGFloat = 0.0
    fileprivate var blue : CGFloat = 0.0
    fileprivate var colorAlpha : CGFloat = 0.0
    fileprivate var archivedColor : Data!
    
    var brushTool : Tool = .pen
    var currentTool : Tool = .pen {
        didSet {
            currentTool.configure(self)
        }
    }
    var loadingProgressBlock : ((_ progress:Double, _ current:Double, _ total:Double) -> Void)?
    
    var color = UIColor.green {
        didSet {
            self.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            self.archivedColor = NSKeyedArchiver.archivedData(withRootObject: self.color)
        }
    }
    
    var drawing : Drawing? {
        didSet {
            DebugConsoleView.debugView.print("set drawing")
            /**
             *  when we set the drawing we can draw everything that's on the server (this is called when we load
             *  a new project)
             */
            guard let drawing = drawing else {
                return
            }
            
            //firebase initialisation
            initFirebase()
            // current drawing tool save
            let p = currentTool
            // get all paths of the current drawing. The closure is called sequencially (path by path)
            let totalPaths = Double(drawing.paths.count)
            var pathPrinted : Double = 1
            drawing.getTexts { (text, error) in
                let textV = DrawableTextView.create(CGPoint(x: CGFloat(text.x.floatValue), y: CGFloat(text.y.floatValue)), text: text.text, color: self.color, drawing: drawing)
                OperationQueue.main.addOperation({ () -> Void in
                    self.addSubview(textV)
                })
            }
            drawing.getPaths({ (paths, error) -> Void in
                
                // get path's points, order them and convert them to CGPoint
                paths.getPoints({ (points, error) -> Void in
                    let cPoint = points.sorted(by: { (p1, p2) -> Bool in
                        return p1.position < p2.position
                    }).map({ (point) -> CGPoint in
                        CGPoint(x:CGFloat(point.x.floatValue), y:CGFloat(point.y.floatValue))
                    })
                    
                    // set path color
                    var color:UIColor? = nil
                    if let col = paths.color {
                        color = NSKeyedUnarchiver.unarchiveObject(with: col) as? UIColor
                    }
                   
                    // marker or pen path
                    self.currentTool = paths.pen ? .pen : .marker
                    
                    // path redrawing
                    let cPath = UIBezierPath()
                    cPath.interpolatePointsWithHermite(cPoint)
                    
                    // path linewidth
                    self.path.lineWidth = paths.lineWidth
                    
                    // if I draw this path I can delete it
                    var layerName = "\(FirebaseKey.undeletable).\(paths.recordId.recordName)"
                    if paths.user == User.currentUser!.recordId.recordName {
                        layerName = "\(paths.recordId.recordName)"
                    }
                    
					self.addPath(cPath.cgPath, layerName: layerName, color: color)
                    self.loadingProgressBlock!((pathPrinted / totalPaths), pathPrinted, totalPaths)
                    pathPrinted = pathPrinted + 1
                    
                    // reset user tools
                    self.currentTool = p
                    self.path.lineWidth = self.lineWidth
                })
            })
            
        }
    }
    
    var project : Project? {
        didSet {
            guard var sublayers = self.superview!.layer.sublayers, let project = project else {
                return
            }
            
            // clear history
            history.removeAll()
            historyIndex = 0
            sublayers = sublayers.filter { (layer) -> Bool in
                if let shapeLayer = layer as? CAShapeLayer {
                    shapeLayer.removeFromSuperlayer()
                    return false
                }
                return true
            }
            for sView in self.subviews {
                if sView is DrawableTextView {
                    sView.removeFromSuperview()
                }
            }
			let size:CGSize
			if project.width != nil {
				size = CGSize(width: CGFloat(project.width.floatValue), height: CGFloat(project.height.floatValue))
			}
			else {
				size = UIScreen.main.bounds.size
			}
			
            self.frame = CGRect(origin: self.frame.origin, size: size)
            if size.width < UIScreen.main.bounds.width {
                self.border(UIColor.draftLinkGrey(), width: 1.0)
            }
            project.getDrawing { (drawing, error) -> Void in
                guard let drawing = drawing else {
                    DebugConsoleView.debugView.errorPrint("empty drawing you should retry in few seconds")
                    return
                }
                self.drawing = drawing
            }
        }
    }
    
    var currentLayer : CALayer? {
        get {
            if history.count > 0 && historyIndex >=  0 && historyIndex < history.count {
                return history[historyIndex].layer
            }
            return nil
        }
    }
    
    var lineWidth : CGFloat = 3.0 {
        didSet {
            path.lineWidth = lineWidth
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        touchCircle.lineWidth = 1
        lineWidth = 2.0
        currentTool = .pen
        isOpaque = false
        backgroundColor = UIColor.clear
    }
    
    /**
     add a path to a layer and insert it to the superview
     
     - parameter path:      CGPath we want to add
     - parameter layerName: String used to identify the layer
     - parameter color:     color of the stroke
     
     - returns: the new layer
     */
    @discardableResult func addPath(_ path:CGPath, layerName:String, color: UIColor? = nil) -> CALayer {
        let layer : CAShapeLayer = {
            $0.path = path
            $0.name = layerName
            $0.lineWidth = self.path.lineWidth
            switch currentTool {
            case .pen:
                $0.lineCap  = kCALineCapRound
                $0.lineJoin = kCALineJoinRound
                break
            case .marker:
                $0.lineCap  = kCALineCapSquare
                $0.lineJoin = kCALineJoinBevel
                break
            default:
                break
            }
            $0.fillColor = UIColor.clear.cgColor
            $0.strokeColor = color == nil ? self.color.cgColor : color!.cgColor
            return $0
        }(CAShapeLayer(layer: self.layer))
        
        self.superview!.layer.insertSublayer(layer, below: self.layer)
        return layer
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if currentTool == .eraser {
            UIColor.white.setFill()
            touchCircle.fill()
        }
        UIColor.lightGray.withAlphaComponent(markerAlpha).setStroke()
        touchCircle.stroke()
        color.setStroke()
        path.stroke()
    }
}

// MARK: - Firebase initialisation
extension DrawableView {
    
    func initFirebase() {
        cbFirebase.firebaseDrawingObserverHandle = cbFirebase.drawing!.observe(FIRDataEventType.childChanged, with: { (snap) -> Void in
            if let arr = snap.value as? [[Dictionary<String, AnyObject>]] {
                let firstPoint = arr.first!
                var red : CGFloat = 0.0
                var green : CGFloat = 0.0
                var blue : CGFloat = 0.0
                var mark : Bool = false
                var lw : CGFloat = 2.0
                var name = ""
                var userName = ""
                
                firstPoint.forEach({ (obj) -> () in
                    if let un = obj[FirebaseKey.drawingUser] {
                        userName = "\(un)"
                    }
                    if let r = obj[FirebaseKey.red] {
                        red = CGFloat(r.floatValue)
                    }
                    else if let g = obj[FirebaseKey.green] {
                        green = CGFloat(g.floatValue)
                    }
                    else if let b = obj[FirebaseKey.blue] {
                        blue = CGFloat(b.floatValue)
                    }
                    else if let pathName = obj[FirebaseKey.pathName] {
                        name = pathName as! String
                    }
                    else if let ma = obj[FirebaseKey.marker] {
                        mark = ma as! Bool
                    }
                    else if let line = obj[FirebaseKey.lineWidth] {
                        lw = CGFloat(line.floatValue)
                    }
                })
                
                let contains = self.history.contains(where: { (tuple: (layer: CALayer, dPath: DrawingPath)) -> Bool in
                    return name == tuple.layer.name
                })
                
                OperationQueue.main.addOperation({ () -> Void in
                    if userName != User.currentUser!.recordId.recordName || !contains {
                        var cPoint =  Array<CGPoint>()
                        arr.forEach({ (obj) -> () in
                            var point = CGPoint.zero
                            obj.forEach({ (mino) -> () in
                                if let x = mino[FirebaseKey.x] {
                                    point.x = CGFloat(x.floatValue)
                                }
                                else if let y = mino[FirebaseKey.y] {
                                    point.y = CGFloat(y.floatValue)
                                }
                            })
                            if point != CGPoint.zero {
                                cPoint.append(point)
                            }
                        })
                        
                        let cPath = UIBezierPath()
                        cPath.removeAllPoints()
                        cPath.interpolatePointsWithHermite(cPoint)
                        var alpha : CGFloat = 1.0
                        let lineW = self.lineWidth
                        let ma = self.currentTool
                        self.currentTool = .pen
                        if mark {
                            self.currentTool = .marker
                            alpha = 0.4
                        }
                        self.lineWidth = lw
                        self.addPath(cPath.cgPath, layerName: "\(FirebaseKey.undeletable).\(name)", color: UIColor(red: red, green: green, blue: blue, alpha: alpha))
                        self.currentTool = ma
                        self.lineWidth = lineW
                    }
                })
            }
            else {
                if let txt = snap.value as? Dictionary<String, AnyObject> {
                    if let username = txt[FirebaseKey.drawingUser] as? String , username != "\(User.currentUser!.recordId.recordName)" {
                        let text = txt["v"] as? String
                        let x = CGFloat(txt["x"]! as! NSNumber)
                        let y = CGFloat(txt["y"]! as! NSNumber)
                        let red : CGFloat = CGFloat(txt[FirebaseKey.red]! as! NSNumber)
                        let green : CGFloat = CGFloat(txt[FirebaseKey.green]! as! NSNumber)
                        let blue : CGFloat = CGFloat(txt[FirebaseKey.blue]! as! NSNumber)
                        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
                        let textV = DrawableTextView.create(CGPoint(x: x, y: y), text: text!, color: color,drawing: self.drawing!)
                        OperationQueue.main.addOperation({ () -> Void in
                            self.addSubview(textV)
                        })
                    }
                }
            }
        }) { (error) -> Void in
            
        }
        cbFirebase.firebaseDeleteObserverHandle = cbFirebase.delete!.observe(FIRDataEventType.childChanged, with: { (snap) -> Void in
            let value = snap.value as! [[String:String]]
            if value.first![FirebaseKey.drawingUser] != User.currentUser!.recordId.recordName {
                self.removeLayerWithName(value.first![FirebaseKey.delete]!)
            }
            
            }, withCancel: { (error) -> Void in
                
        })
    }
}

// MARK: - Touches handler
extension DrawableView {
	
	@objc(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:) func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return !(gestureRecognizer is UITapGestureRecognizer)
	}
	
    func panGesture(_ panGesture:UIPanGestureRecognizer) {
        let currentPoint = panGesture.location(in: self)
        guard let _ = self.drawing else {
            return
        }
        touchCircle.removeAllPoints()
        touchCircle.addArc(withCenter: currentPoint, radius: 5.0, startAngle: 0.0, endAngle: 2*CGFloat(M_PI), clockwise: true)
        if currentTool == .eraser {
            self.removeAtPoint(currentPoint)
            self.setNeedsDisplay()
            if panGesture.state == .ended {
                touchCircle.removeAllPoints()
            }
            return
        }
        interPolationPoints.append(currentPoint)
        path.removeAllPoints()
        path.interpolatePointsWithHermite(interPolationPoints)
        switch panGesture.state {
        case .began:
            path.move(to: currentPoint)
            break
        case .changed:
            break
        case .ended, .cancelled, .failed:
            let dPath = DrawingPath.create(self.drawing!, completion:nil)
            dPath.color = self.archivedColor
            dPath.pen = currentTool == .pen
            dPath.lineWidth = self.lineWidth
            let recPoints = Point.createBatch(interPolationPoints, dPath: dPath)
			var dico = [[String: AnyObject]]()
			dico.append([FirebaseKey.drawingUser:"\(User.currentUser!.recordId.recordName)" as AnyObject])
			
			self.interPolationPoints.forEach({ (point) in
				dico.append([FirebaseKey.x:NSNumber(value: Float(point.x))])
				dico.append([FirebaseKey.y:NSNumber(value: Float(point.y))])
			})
			
			dico.append([FirebaseKey.red:NSNumber(value: Float(self.red))])
			dico.append([FirebaseKey.green:NSNumber(value: Float(self.green))])
			dico.append([FirebaseKey.blue:NSNumber(value: Float(self.blue))])
			dico.append([FirebaseKey.pathName:dPath.recordId.recordName as AnyObject])
			dico.append([FirebaseKey.marker:(self.currentTool == .marker) as AnyObject])
			dico.append([FirebaseKey.lineWidth:self.lineWidth as AnyObject])
			OperationQueue().addOperation({ () -> Void in
				                cbFirebase.drawing!.updateChildValues([FirebaseKey.points:dico])
				})			
            dPath.points.append(contentsOf: recPoints.records.map({ (record) -> CKReference in
                CKReference(record: record, action: CKReferenceAction.none)
            }))
            dPath.saveBulk(recPoints.records, completion: nil)
            dPath.localSave(recPoints.points)
            interPolationPoints.removeAll()
            let newLayer = self.addPath(path.cgPath, layerName: dPath.recordId.recordName)
            history.append((newLayer, dPath))
            historyIndex = history.count - 1
            path.removeAllPoints()
            touchCircle.removeAllPoints()
            layerIndex += 1
            break
        default:
            break
        }
        self.setNeedsDisplay()
    }
    
    func addText(_ tapGesture:UITapGestureRecognizer) {
        let currentPoint = tapGesture.location(in: self)
        if currentTool == .text, let drawing = drawing {
			let textV = DrawableTextView.create(currentPoint, text: "put text", color: color, drawing: drawing)
			addSubview(textV)
        }
    }
}

// MARK: - tools methods
extension DrawableView {
    
    func getCurrentTool() -> Tool {
        return currentTool
    }
    
    func clear() {
        history.forEach { (val: (layer: CALayer, dPath: DrawingPath)) -> () in
            val.dPath.remove()
            self.removeLayerWithName(val.layer.name!)
        }
        history.removeAll()
        historyIndex = 0
        self.setNeedsDisplay()
    }
    
    func undo() {
        guard let currentLayer = currentLayer else {
            return
        }
        cbFirebase.delete!.updateChildValues([FirebaseKey.delete:[[FirebaseKey.delete: history.last!.layer.name!],[FirebaseKey.drawingUser:User.currentUser!.recordId.recordName]]])
        history[historyIndex].dPath.remove()
        self.removeLayerWithName(currentLayer.name!)
        historyIndex -= 1
        self.setNeedsDisplay()
    }
    
    func redo() {
        if historyIndex >= 0 && historyIndex < history.count - 1 {
            history[historyIndex].dPath.publicSave({ (record, error) -> Void in
                DebugConsoleView.debugView.print("\(error)")
            })
            historyIndex += 1
            self.superview?.layer.addSublayer(history[historyIndex].layer)
        }
    }
    
    func removeLayerWithName(_ name:String) {
        guard let sublayers = self.superview!.layer.sublayers else {
            return
        }
        _ = sublayers.forEach { (layer) -> () in
            if let shapeLayer = layer as? CAShapeLayer  {
                if shapeLayer.name!.contains(name) {
                    shapeLayer.removeFromSuperlayer()
                }
            }
        }
    }
    
    func removeAtPoint(_ point:CGPoint) {
        guard let sublayers = self.superview!.layer.sublayers else {
            return
        }
        _ = sublayers.forEach { (layer) -> () in
            if let shapeLayer = layer as? CAShapeLayer {
                if let path = shapeLayer.path {
                    let bezierPath = UIBezierPath(cgPath:path)
                    if bezierPath.contains(point) {
                        if !shapeLayer.name!.contains(FirebaseKey.undeletable) {
                            cbFirebase.delete!.updateChildValues([FirebaseKey.delete:[[FirebaseKey.delete: shapeLayer.name!],[FirebaseKey.drawingUser:User.currentUser!.recordId.recordName]]])
                            let index = history.index(where: { (tuple: (layer: CALayer, dPath: DrawingPath)) -> Bool in
                                return tuple.layer == shapeLayer
                            })
                            if let index = index {
                                let value = history[index]
                                value.dPath.remove()
                                history.remove(at: index)
                                shapeLayer.removeFromSuperlayer()
                                return
                            }
                            else {
                                DrawingPath.removeWithName(shapeLayer.name!)
                            }
                        }
                    }
                }
            }
        }
    }
}
