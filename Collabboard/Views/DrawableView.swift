//
//  DrawableView.swift
//  Mentor
//
//  Created by Alexandre on 11/10/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit
import CloudKit
import Firebase
import ABUIKit

//TODO: manage multi size screen (simple solution : create a view with the max screen size)
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
    
    var loadingProgressBlock : ((progress:Double, current:Double, total:Double) -> Void)?
    
    var color = UIColor.greenColor() {
        didSet {
            self.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            self.archivedColor = NSKeyedArchiver.archivedDataWithRootObject(self.color)
        }
    }
    
    var eraser = false
    var marker = false {
        didSet {
            if marker {
                self.color = self.color.colorWithAlphaComponent(markerAlpha)
                pen = false
            }
        }
    }
    var pen = false {
        didSet {
            if pen {
                self.color = self.color.colorWithAlphaComponent(1.0)
                marker = false
            }
        }
    }

    var drawing : Drawing? {
        didSet {
            DebugConsoleView.debugView.print("set drawing")
            /**
            *  when we set the drawing we can draw everything that's on the server (this is called when we load
            *  a new project)
            */
            if (drawing != nil) {
                //firebase initialisation
                initFirebase()
                // current drawing tool save
                let p = self.pen
                let m = self.marker
                // get all paths of the current drawing. The closure is called sequencially (path by path)
                let totalPaths = Double(self.drawing!.paths.count)
                var pathPrinted : Double = 1
                self.drawing!.getPaths({ (paths, error) -> Void in
                    // get path's points, order them and convert them to CGPoint
                    paths.getPoints({ (points, error) -> Void in
                        
                        let cPoint = points.sort({ (p1, p2) -> Bool in
                            return p1.position < p2.position
                        }).map({ (point) -> CGPoint in
                            CGPoint(x:CGFloat(point.x.floatValue), y:CGFloat(point.y.floatValue))
                        })
                        // path redrawing
                        let cPath = UIBezierPath()
                        cPath.interpolatePointsWithHermite(cPoint)
                        // set path color
                        var color:UIColor? = nil
                        if let col = paths.color {
                            color = NSKeyedUnarchiver.unarchiveObjectWithData(col) as? UIColor
                        }
                        // marker or pen path
                        if paths.pen {
                            self.pen = true
                        }
                        else {
                            self.marker = true
                        }
                        // path linewidth
                        self.path.lineWidth = paths.lineWidth
                        // if I draw this path I can delete it
                        if paths.user == KCurrentUser!.recordId.recordName {
                            self.addPath(cPath.CGPath, layerName: "\(paths.recordId.recordName)",color: color)
                        }
                        else {
                            self.addPath(cPath.CGPath, layerName: "\(FirebaseKey.undeletable).\(paths.recordId.recordName)",color: color)
                        }
                        self.loadingProgressBlock!(progress: (pathPrinted++ / totalPaths), current:pathPrinted, total:totalPaths)
                        // reset user tools
                        self.pen = p
                        self.marker = m
                        self.path.lineWidth = self.lineWidth
                    })
                })
            }
        }
    }

    var project : Project? {
        didSet {
            guard var sublayers = self.superview!.layer.sublayers else {
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
            let size = CGSize(width: CGFloat(project!.width.floatValue), height: CGFloat(project!.height.floatValue))
            self.frame = CGRect(origin: self.frame.origin, size: size)
            if size.width < UIScreen.mainScreen().bounds.width {
                self.border(UIColor.blackColor(), width: 1.0)
            }
            project!.getDrawing { (drawing, error) -> Void in
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
        pen = true
        self.opaque = false
        self.backgroundColor = UIColor.clearColor()
    }
    
    /**
     add a path to a layer and insert it to the superview
     
     - parameter path:      CGPath we want to add
     - parameter layerName: String used to identify the layer
     - parameter color:     color of the stroke
     
     - returns: the new layer
     */
    func addPath(path:CGPath, layerName:String, color: UIColor? = nil) -> CALayer {
        let layer = CAShapeLayer(layer: self.layer)
        layer.path = path
        layer.name = layerName
        layer.lineWidth = self.path.lineWidth
        if pen {
            layer.lineCap  = kCALineCapRound
            layer.lineJoin = kCALineJoinRound
        }
        layer.fillColor = UIColor.clearColor().CGColor
        if marker {
            layer.lineCap  = kCALineCapSquare
            layer.lineJoin = kCALineJoinBevel
        }
        layer.strokeColor = color == nil ? self.color.CGColor : color!.CGColor
        self.superview!.layer.insertSublayer(layer, below: self.layer)
        return layer
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if eraser {
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
    /**
     initialisation of firebase
     there is 2 firebase events we want to observe : 
        1) when a user draw something
            - in that case the object received from firebase is an array containing all the points of the new path
            and all the informations relative to that path 
     array : [
        [
            [0] =  {
                // user who draw the path
                drawingUser = "_360c5dfd1b920a7108d1340c2ba14cd7"
            }
            [1] =  {
                // x coordinate
                x = 170
            }
            [2] = {
                // y coordinate
                y = 127
            }
            [3] = {
                // red componant
                red = 0.2
            }
            [4] = {
                // green componant
                green = 1
            }
            [5] = {
                // blue componant
                blue = 0
            }
            [6] = {
                // path name
                pathName = ""
            }
            [7] = {
                // if the user used the marker tool
                marker = false
            }
            [8] = {
                // line width used
                lineWidth = 2
            }
        ]
     ...
     ]
     
     
        2) when a user delete a path
     
     */
    func initFirebase() {
        cbFirebase.firebaseDrawingObserverHandle = cbFirebase.drawing!.observeEventType(FEventType.ChildChanged, withBlock: { (snap) -> Void in
            let arr = snap.value as! [[Dictionary<String, AnyObject>]]
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
                if userName != KCurrentUser!.recordId.recordName || !contains {
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
                    let ma = self.marker
                    let pe = self.pen
                    if mark {
                        self.marker = mark
                        alpha = self.markerAlpha
                    }
                    else {
                        self.pen = true
                    }
                    self.lineWidth = lw
                    self.addPath(cPath.CGPath, layerName: "\(FirebaseKey.undeletable).\(name)", color: UIColor(red: red, green: green, blue: blue, alpha: alpha))
                    self.pen = pe
                    self.marker = ma
                    self.lineWidth = lineW
                }
            })
            
            }) { (error) -> Void in
                
        }
        cbFirebase.firebaseDeleteObserverHandle = cbFirebase.delete!.observeEventType(FEventType.ChildChanged, withBlock: { (snap) -> Void in
            let value = snap.value as! [[String:String]]
            if value.first![FirebaseKey.drawingUser] != KCurrentUser!.recordId.recordName {
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
        if eraser {
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
            dPath.pen = self.pen
            dPath.lineWidth = self.lineWidth
            let recPoints = Point.createBatch(interPolationPoints, dPath: dPath)
            NSOperationQueue().addOperationWithBlock({ () -> Void in
                cbFirebase.drawing!.updateChildValues([FirebaseKey.points:  self.interPolationPoints.map({ (point) -> [[String:AnyObject]] in
                    return [[FirebaseKey.drawingUser:"\(KCurrentUser!.recordId.recordName)"],[FirebaseKey.x:NSNumber(float: Float(point.x))], [FirebaseKey.y:NSNumber(float: Float(point.y))], [FirebaseKey.red:NSNumber(float: Float(self.red))],[FirebaseKey.green:NSNumber(float: Float(self.green))],[FirebaseKey.blue:NSNumber(float: Float(self.blue))],[FirebaseKey.pathName:dPath.recordId.recordName],[FirebaseKey.marker:self.marker], [FirebaseKey.lineWidth:self.lineWidth]]
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
            layerIndex++
            break
        default:
            break
        }
        self.setNeedsDisplay()
    }
}

// MARK: - tools methods
extension DrawableView {
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
        cbFirebase.delete!.updateChildValues([FirebaseKey.delete:[[FirebaseKey.delete: history.last!.layer.name!],[FirebaseKey.drawingUser:KCurrentUser!.recordId.recordName]]])
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
                            cbFirebase.delete!.updateChildValues([FirebaseKey.delete:[[FirebaseKey.delete: shapeLayer.name!],[FirebaseKey.drawingUser:KCurrentUser!.recordId.recordName]]])
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