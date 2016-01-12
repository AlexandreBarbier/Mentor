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
//TODO: Fix pen size after update

struct FirebaseKey {
    static let red = "r"
    static let green = "g"
    static let blue = "b"
    static let pathName = "pn"
    static let x = "x"
    static let y = "y"
    static let points = "po"
    static let delete = "del"
    static let marker = "mark"
        static let lineWidth = "lw"
    static let undeletable = "undeletable"
}

class DrawableView: UIView, UIGestureRecognizerDelegate {
    
    private var layerIndex = 0
    private var path = UIBezierPath()
    private var history = [(layer:CALayer,dPath:DrawingPath)]()
    private var historyIndex = 0
    private var interPolationPoints = [CGPoint] ()
    private var firbaseDrawing : Firebase!
    private var firebaseDelete : Firebase!
    private var isSource = false
    private var touchCircle = UIBezierPath()
    private var firebaseDrawingObserverHandle : UInt = 0
    private var firebaseDeleteObserverHandle : UInt = 0
    private var red : CGFloat = 0.0
    private var green : CGFloat = 0.0
    private var blue : CGFloat = 0.0
    private var colorAlpha : CGFloat = 0.0
    private var archivedColor : NSData!
    
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
                self.color = self.color.colorWithAlphaComponent(0.6)
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
            if (drawing != nil) {
                initFirebase()
                self.drawing!.getPaths({ (paths, error) -> Void in
                    paths.getPoints({ (points, error) -> Void in
                        let cPoint = points.sort({ (p1, p2) -> Bool in
                            return p1.position < p2.position
                        }).map({ (point) -> CGPoint in
                            CGPoint(x:CGFloat(point.x.floatValue), y:CGFloat(point.y.floatValue))
                        })
                        let cPath = UIBezierPath()
                        cPath.interpolatePointsWithHermite(cPoint)
                        var color:UIColor? = nil
                        if let col = paths.color {
                            color = NSKeyedUnarchiver.unarchiveObjectWithData(col) as? UIColor
                        }
                        if paths.pen {
                            self.pen = true
                        }
                        else {
                            self.marker = true
                        }
                        self.path.lineWidth = paths.lineWidth

                        self.addPath(cPath.CGPath, layerName: "\(FirebaseKey.undeletable).\(paths.recordId.recordName)",color: color)
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
                guard let drawing = drawing.first else {
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
        UIColor.lightGrayColor().colorWithAlphaComponent(0.4).setStroke()
        touchCircle.stroke()
        color.setStroke()
        path.stroke()
    }
}

// MARK: - Firebase initialisation
extension DrawableView {
    func initFirebase() {
        if let firbaseDrawing = firbaseDrawing {
            firbaseDrawing.removeObserverWithHandle(firebaseDrawingObserverHandle)
        }
        firbaseDrawing = Firebase(url: "\(Constants.NetworkURL.firebase.rawValue)\(project!.recordName)/drawing/")
        firebaseDrawingObserverHandle = firbaseDrawing!.observeEventType(FEventType.ChildChanged, withBlock: { (snap) -> Void in
            if !self.isSource {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let arr = snap.value as! [[Dictionary<String, AnyObject>]]
                    var cPoint = Array<CGPoint>()
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
                        cPoint.append(point)
                    })
                    let firstPoint = arr.first!
                    var red : CGFloat = 0.0
                    var green : CGFloat = 0.0
                    var blue : CGFloat = 0.0
                    var mark : Bool = false
                    var lw : CGFloat = 2.0
                    var name = ""
                    firstPoint.forEach({ (obj) -> () in
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
                    
                    let cPath = UIBezierPath()
                    cPath.removeAllPoints()
                    cPath.interpolatePointsWithHermite(cPoint)
                    var alpha : CGFloat = 1.0
                    if mark {
                        self.marker = mark
                        alpha = 0.6
                    }
                    else {
                        self.pen = true
                    }
                    self.lineWidth = lw
                    self.addPath(cPath.CGPath, layerName: "\(FirebaseKey.undeletable).\(name)", color: UIColor(red: red, green: green, blue: blue, alpha: alpha))
                })
            }
            self.isSource = false
            }) { (error) -> Void in
                
        }
        if let firebaseDelete = firebaseDelete {
            firebaseDelete.removeObserverWithHandle(firebaseDeleteObserverHandle)
        }
        firebaseDelete = Firebase(url: "\(Constants.NetworkURL.firebase.rawValue)\(project!.recordName)/delete")
        firebaseDeleteObserverHandle = firebaseDelete!.observeEventType(FEventType.ChildChanged, withBlock: { (snap) -> Void in
            if !self.isSource {
                let layerName = snap.value as! String
                self.removeLayerWithName(layerName)
            }
            self.isSource = false
            }, withCancelBlock: { (error) -> Void in
                
        })
        
    }
}

// MARK: - Touches handler
extension DrawableView {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            return false
        }
        return true
    }
    
    func panGesture(panGesture:UIPanGestureRecognizer) {
        let currentPoint = panGesture.locationInView(self)
        guard let _ = self.drawing else {
            return
        }
        touchCircle.removeAllPoints()
        touchCircle.addArcWithCenter(currentPoint, radius: 5.0, startAngle: 0.0, endAngle: 6.28, clockwise: true)
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
            let recPoints = Point.createBatch(interPolationPoints,dPath: dPath)
            self.isSource = true
            firbaseDrawing!.updateChildValues([FirebaseKey.points:  interPolationPoints.map({ (point) -> [[String:AnyObject]] in
                return [[FirebaseKey.x:NSNumber(float: Float(point.x))], [FirebaseKey.y:NSNumber(float: Float(point.y))], [FirebaseKey.red:NSNumber(float: Float(red))],[FirebaseKey.green:NSNumber(float: Float(green))],[FirebaseKey.blue:NSNumber(float: Float(blue))],[FirebaseKey.pathName:dPath.recordId.recordName],[FirebaseKey.marker:marker], [FirebaseKey.lineWidth:self.lineWidth]]
            })
                ])
            dPath.points.appendContentsOf(recPoints.0.map({ (record) -> CKReference in
                CKReference(record: record, action: CKReferenceAction.None)
            }))
            dPath.saveBulk(recPoints.0, completion: nil)
            dPath.localSave(recPoints.1)
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
            self.removeLayerWithName(layer.name!)
        }
        history.removeAll()
        historyIndex = 0
        self.setNeedsDisplay()
    }
    
    func undo() {
        guard let currentLayer = currentLayer else {
            return
        }
        firebaseDelete!.updateChildValues([FirebaseKey.delete: history.last!.layer.name!])
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
                    if bezierPath.bounds.contains(point) {
                        if !shapeLayer.name!.containsString(FirebaseKey.undeletable) {
                            self.isSource = true
                            firebaseDelete!.updateChildValues([FirebaseKey.delete: shapeLayer.name!])
                            let index = history.indexOf({ (_: (layer: CALayer, dPath: DrawingPath)) -> Bool in
                                if layer == shapeLayer {
                                    return true
                                }
                                return false
                            })
                            if let index = index {
                                let value = history[index]
                                value.dPath.remove()
                                history.removeAtIndex(index)
                                shapeLayer.removeFromSuperlayer()
                                return
                            }
                        }
                    }
                }
            }
        }
    }
}