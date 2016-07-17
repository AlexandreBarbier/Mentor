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
    private var markerAlpha : CGFloat = 0.4
    private var layerIndex = 0
    private var path = UIBezierPath()
    private var history = [(layer:CALayer,dPath:DrawingPath)]()
    private var historyIndex = 0
    private var interPolationPoints = [CGPoint] ()
    private var touchCircle = UIBezierPath()
    private var red : CGFloat = 0.0
    private var green : CGFloat = 0.0
    private var blue : CGFloat = 0.0
    private var colorAlpha : CGFloat = 0.0
    private var archivedColor : NSData!
    
    var brushTool : Tool = .pen
    var currentTool : Tool = .pen {
        didSet {
            currentTool.configure(self)
        }
    }
    var loadingProgressBlock : ((progress:Double, current:Double, total:Double) -> Void)?
    
    var color = UIColor.greenColor() {
        didSet {
            self.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            self.archivedColor = NSKeyedArchiver.archivedDataWithRootObject(self.color)
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
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.addSubview(textV)
                })
            }
            drawing.getPaths({ (paths, error) -> Void in
                
                // get path's points, order them and convert them to CGPoint
                paths.getPoints({ (points, error) -> Void in
                    let cPoint = points.sort({ (p1, p2) -> Bool in
                        return p1.position < p2.position
                    }).map({ (point) -> CGPoint in
                        CGPoint(x:CGFloat(point.x.floatValue), y:CGFloat(point.y.floatValue))
                    })
                    
                    // set path color
                    var color:UIColor? = nil
                    if let col = paths.color {
                        color = NSKeyedUnarchiver.unarchiveObjectWithData(col) as? UIColor
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
                    
                    self.addPath(cPath.CGPath, layerName: layerName, color: color)
                    self.loadingProgressBlock!(progress: (pathPrinted / totalPaths), current:pathPrinted, total:totalPaths)
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
            let size = CGSize(width: CGFloat(project.width.floatValue), height: CGFloat(project.height.floatValue))
            self.frame = CGRect(origin: self.frame.origin, size: size)
            if size.width < UIScreen.mainScreen().bounds.width {
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
        opaque = false
        backgroundColor = UIColor.clearColor()
    }
    
    /**
     add a path to a layer and insert it to the superview
     
     - parameter path:      CGPath we want to add
     - parameter layerName: String used to identify the layer
     - parameter color:     color of the stroke
     
     - returns: the new layer
     */
    func addPath(path:CGPath, layerName:String, color: UIColor? = nil) -> CALayer {
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
            $0.fillColor = UIColor.clearColor().CGColor
            $0.strokeColor = color == nil ? self.color.CGColor : color!.CGColor
            return $0
        }(CAShapeLayer(layer: self.layer))
        
        self.superview!.layer.insertSublayer(layer, below: self.layer)
        return layer
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if currentTool == .eraser {
            UIColor.whiteColor().setFill()
            touchCircle.fill()
        }
        UIColor.lightGrayColor().colorWithAlphaComponent(markerAlpha).setStroke()
        touchCircle.stroke()
        color.setStroke()
        path.stroke()
    }
}

// MARK: - Firebase initialisation
extension DrawableView {
    
    func initFirebase() {
        cbFirebase.firebaseDrawingObserverHandle = cbFirebase.drawing!.observeEventType(FIRDataEventType.ChildChanged, withBlock: { (snap) -> Void in
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
                
                let contains = self.history.contains({ (tuple: (layer: CALayer, dPath: DrawingPath)) -> Bool in
                    return name == tuple.layer.name
                })
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if userName != User.currentUser!.recordId.recordName || !contains {
                        var cPoint =  Array<CGPoint>()
                        arr.forEach({ (obj) -> () in
                            var point = CGPointZero
                            obj.forEach({ (mino) -> () in
                                if let x = mino[FirebaseKey.x] {
                                    point.x = CGFloat(x.floatValue)
                                }
                                else if let y = mino[FirebaseKey.y] {
                                    point.y = CGFloat(y.floatValue)
                                }
                            })
                            if point != CGPointZero {
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
                        self.addPath(cPath.CGPath, layerName: "\(FirebaseKey.undeletable).\(name)", color: UIColor(red: red, green: green, blue: blue, alpha: alpha))
                        self.currentTool = ma
                        self.lineWidth = lineW
                    }
                })
            }
            else {
                if let txt = snap.value as? Dictionary<String, AnyObject> {
                    if let username = txt[FirebaseKey.drawingUser] as? String where username != "\(User.currentUser!.recordId.recordName)" {
                        let text = txt["v"] as? String
                        let x = CGFloat(txt["x"]! as! NSNumber)
                        let y = CGFloat(txt["y"]! as! NSNumber)
                        let red : CGFloat = CGFloat(txt[FirebaseKey.red]! as! NSNumber)
                        let green : CGFloat = CGFloat(txt[FirebaseKey.green]! as! NSNumber)
                        let blue : CGFloat = CGFloat(txt[FirebaseKey.blue]! as! NSNumber)
                        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
                        let textV = DrawableTextView.create(CGPoint(x: x, y: y), text: text!, color: color,drawing: self.drawing!)
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.addSubview(textV)
                        })
                    }
                }
            }
        }) { (error) -> Void in
            
        }
        cbFirebase.firebaseDeleteObserverHandle = cbFirebase.delete!.observeEventType(FIRDataEventType.ChildChanged, withBlock: { (snap) -> Void in
            let value = snap.value as! [[String:String]]
            if value.first![FirebaseKey.drawingUser] != User.currentUser!.recordId.recordName {
                self.removeLayerWithName(value.first![FirebaseKey.delete]!)
            }
            
            }, withCancelBlock: { (error) -> Void in
                
        })
    }
}

// MARK: - Touches handler
extension DrawableView {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(gestureRecognizer is UITapGestureRecognizer)
    }
    
    func panGesture(panGesture:UIPanGestureRecognizer) {
        let currentPoint = panGesture.locationInView(self)
        guard let _ = self.drawing else {
            return
        }
        touchCircle.removeAllPoints()
        touchCircle.addArcWithCenter(currentPoint, radius: 5.0, startAngle: 0.0, endAngle: 2*CGFloat(M_PI), clockwise: true)
        if currentTool == .eraser {
            self.removeAtPoint(currentPoint)
            self.setNeedsDisplay()
            if panGesture.state == .Ended {
                touchCircle.removeAllPoints()
            }
            return
        }
        interPolationPoints.append(currentPoint)
        path.removeAllPoints()
        path.interpolatePointsWithHermite(interPolationPoints)
        switch panGesture.state {
        case .Began:
            path.moveToPoint(currentPoint)
            break
        case .Changed:
            break
        case .Ended, .Cancelled, .Failed:
            let dPath = DrawingPath.create(self.drawing!, completion:nil)
            dPath.color = self.archivedColor
            dPath.pen = currentTool == .pen
            dPath.lineWidth = self.lineWidth
            let recPoints = Point.createBatch(interPolationPoints, dPath: dPath)
            NSOperationQueue().addOperationWithBlock({ () -> Void in
                cbFirebase.drawing!.updateChildValues([FirebaseKey.points:  self.interPolationPoints.map({ (point) -> [[String:AnyObject]] in
                    return [[FirebaseKey.drawingUser:"\(User.currentUser!.recordId.recordName)"],[FirebaseKey.x:NSNumber(float: Float(point.x))], [FirebaseKey.y:NSNumber(float: Float(point.y))], [FirebaseKey.red:NSNumber(float: Float(self.red))],[FirebaseKey.green:NSNumber(float: Float(self.green))],[FirebaseKey.blue:NSNumber(float: Float(self.blue))],[FirebaseKey.pathName:dPath.recordId.recordName],[FirebaseKey.marker:self.currentTool == .marker], [FirebaseKey.lineWidth:self.lineWidth]]
                })
                    ])
            })
            
            dPath.points.appendContentsOf(recPoints.records.map({ (record) -> CKReference in
                CKReference(record: record, action: CKReferenceAction.None)
            }))
            dPath.saveBulk(recPoints.records, completion: nil)
            dPath.localSave(recPoints.points)
            interPolationPoints.removeAll()
            let newLayer = self.addPath(path.CGPath, layerName: dPath.recordId.recordName)
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
    
    func addText(tapGesture:UITapGestureRecognizer) {
        let currentPoint = tapGesture.locationInView(self)
        if currentTool == .text {
            let textV = DrawableTextView.create(currentPoint, text: "put text", color: color, drawing: self.drawing!)
            self.addSubview(textV)
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
    
    func removeLayerWithName(name:String) {
        guard let sublayers = self.superview!.layer.sublayers else {
            return
        }
        _ = sublayers.forEach { (layer) -> () in
            if let shapeLayer = layer as? CAShapeLayer  {
                if shapeLayer.name!.containsString(name) {
                    shapeLayer.removeFromSuperlayer()
                }
            }
        }
    }
    
    func removeAtPoint(point:CGPoint) {
        guard let sublayers = self.superview!.layer.sublayers else {
            return
        }
        _ = sublayers.forEach { (layer) -> () in
            if let shapeLayer = layer as? CAShapeLayer {
                if let path = shapeLayer.path {
                    let bezierPath = UIBezierPath(CGPath:path)
                    if bezierPath.containsPoint(point) {
                        if !shapeLayer.name!.containsString(FirebaseKey.undeletable) {
                            cbFirebase.delete!.updateChildValues([FirebaseKey.delete:[[FirebaseKey.delete: shapeLayer.name!],[FirebaseKey.drawingUser:User.currentUser!.recordId.recordName]]])
                            let index = history.indexOf({ (tuple: (layer: CALayer, dPath: DrawingPath)) -> Bool in
                                return tuple.layer == shapeLayer
                            })
                            if let index = index {
                                let value = history[index]
                                value.dPath.remove()
                                history.removeAtIndex(index)
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