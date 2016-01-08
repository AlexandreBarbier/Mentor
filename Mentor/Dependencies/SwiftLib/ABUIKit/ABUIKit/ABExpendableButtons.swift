//
//  ABExpendableButtons.swift
//  ABUIKit
//
//  Created by Alexandre barbier on 16/10/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

public enum ABOrientation : Int, CustomStringConvertible {
    case Horizontal
    case Vertical
    case None
    public var description : String {
        get {
            switch self {
            case .Horizontal :
                return "Horizontal"
            case .Vertical :
                return "Vertical"
            case .None :
                return "Both"
            }
            
        }
    }
}

public enum ABDirection : Int, CustomStringConvertible {
    case Up
    case Down
    case Left
    case Right
    public var description : String {
        get {
            switch self {
            case .Up :
                return "Up"
            case .Down :
                return "Down"
            case .Left :
                return "Left"
            case .Right :
                return "Right"
            }
        }
    }
}

public class ABExpendableButton: UIView {
    public var mainOrientation : ABOrientation = .Horizontal
    public var changedOrientation : ((orientation:ABOrientation) -> Void)?
    public var openOrientation : ABOrientation = .Horizontal {
        didSet {
            if let changeOr = self.changedOrientation {
                changeOr(orientation: openOrientation)
            }
        }
    }
    var borderColor = UIColor.blackColor()
    var backColor = UIColor.whiteColor()

    public var verticaleDirection : ABDirection = .Down {
        didSet {
            switch verticaleDirection {
            case .Up :
                self.closeButton.autoresizingMask = [self.closeButton.autoresizingMask,UIViewAutoresizing.FlexibleTopMargin]
                
            default :
                return
            }
        }
    }
    
    public var horizontalDirection : ABDirection = .Left {
        didSet {
            switch horizontalDirection {
            case .Left :
                self.closeButton.autoresizingMask = [self.closeButton.autoresizingMask,UIViewAutoresizing.FlexibleLeftMargin]
            default :
                return
            }
        }
    }
    
    private var isClosed = true
    private var closeButton = UIButton()
    public var horizontalButtons : Dictionary<UIButton, (sender:UIButton) -> Void> = Dictionary<UIButton, (sender:UIButton) -> Void>()
    
    public func addHorizontalButton (buttons:Dictionary<String, (sender:UIButton) -> Void>) -> Void {
        for (key, _) in self.horizontalButtons {
            key.removeFromSuperview()
        }
        self.horizontalButtons.removeAll(keepCapacity: false)
        let fr = CGRect(x: 8.0,y: 8.0, width: 44.0,height: 44.0)
        for (key, value) in buttons {
            let button = UIButton(frame: fr)
            button.setImage(UIImage(named: key), forState: UIControlState.Normal)
            button.addTarget(self, action: "buttonTouched:" , forControlEvents: UIControlEvents.TouchUpInside)
            button.circle()
            button.border(self.borderColor, width: UIScreen.mainScreen().scale)
            button.layer.masksToBounds = false
            button.backgroundColor = self.backColor
            self.horizontalButtons.updateValue(value, forKey: button)
            switch horizontalDirection {
            case .Left :
                button.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin]
                
            default :
                break
            //    fatalError("No direction that's weird")
            }
            self.addSubview(button)
            
        }
        self.bringSubviewToFront(self.viewWithTag(-1)!)
    }
    
    public var verticalButtons : Dictionary<UIButton, (sender:UIButton) -> Void> = Dictionary<UIButton, (sender:UIButton) -> Void>()
    
    public func addVerticalButton (buttons:Dictionary<String, (sender:UIButton) -> Void>) -> Void {
        for (key, _) in self.verticalButtons {
            key.removeFromSuperview()
        }
        self.verticalButtons.removeAll(keepCapacity: false)
        let fr = CGRect(x: 8,y: 8,width: 44,height: 44)
        for (key, value) in buttons {
            let button = UIButton(frame: fr)
            button.setImage(UIImage(named: key), forState: UIControlState.Normal)
            button.addTarget(self, action: "buttonTouched:" , forControlEvents: UIControlEvents.TouchUpInside)
            button.circle()
            button.backgroundColor = self.backColor
            button.border(UIColor.blackColor(),width: 1.0)
            switch verticaleDirection {
            case .Up :
                button.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin , UIViewAutoresizing.FlexibleTopMargin]
            default :
                fatalError("No direction that's weird")
            }
            self.verticalButtons.updateValue(value, forKey: button)
            self.addSubview(button)
            
        }
        self.bringSubviewToFront(self.viewWithTag(-1)!)
    }
    
    public func openOtherOrientation() -> Void {
        if self.isClosed {
            switch self.mainOrientation {
            case .Horizontal:
                self.openOrientation = .Vertical
                self.animateButtons(.Vertical)
            case .Vertical :
                self.openOrientation = .Horizontal
                self.animateButtons(.Horizontal)
            default :
                fatalError("No orientation")
                
            }
            
        }
    }
    
    internal func buttonTouched(sender:UIButton) {
        if sender.tag == -1 {
            if !self.isClosed {
                animateButtons(self.openOrientation)
            }
            else {
                self.openOrientation = self.mainOrientation
                animateButtons(self.mainOrientation)
            }
        }
        else {
            var t = verticalButtons[sender]
            if t == nil {
                t = horizontalButtons[sender]
            }

        self.close(nil, sender: sender)
            t!(sender: sender)
            
        }
    }

    
    internal func animateButtons(orientation: ABOrientation) {
        if self.isClosed {
            self.isClosed = false
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                
                var offset : CGFloat = 52.0
                switch orientation {
                case .Horizontal:
                    switch self.horizontalDirection {
                    case .Left :
                        offset = -52.0
                    case .Right :
                        offset = 52.0
                    default :
                        offset = 0
                    }
                case .Vertical :
                    switch self.verticaleDirection {
                    case .Up :
                        offset = -52.0
                    case .Down :
                        offset = 52.0
                    default :
                        offset = 0
                    }
                default :
                    fatalError("")
                }
                
                switch orientation {
                case .Horizontal:
                    if self.horizontalDirection == .Left {
                        self.layer.transform = CATransform3DMakeTranslation(-(self.superview!.frame.width - self.frame.width), 0, 0)
                    }
                    
                    self.frame.size.width = self.superview!.frame.size.width
                    for (button , _) in self.horizontalButtons {
                        button.layer.transform = CATransform3DMakeTranslation(offset, 0, 0)
                        
                        switch self.horizontalDirection {
                        case .Left :
                            offset -= 52.0
                        case .Right :
                            offset += 52.0
                        default :
                            offset = 0
                        }
                    }
                case .Vertical:
                    if self.verticaleDirection == .Up {
                        self.layer.transform = CATransform3DMakeTranslation(0, -(self.superview!.frame.height - self.frame.height), 0)
                    }
                    self.frame.size.height = self.superview!.frame.size.height
                    for (button , _) in self.verticalButtons {
                        
                        button.layer.transform = CATransform3DMakeTranslation(0, offset, 0)
                        switch self.verticaleDirection {
                        case .Up :
                            offset -= 52.0
                        case .Down :
                            offset += 52.0
                        default :
                            offset = 0
                        }
                    }
                default:
                    fatalError("tets")
                }
                self.closeButton.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_4), 0, 0, 1)
                }, completion:{ (finished) -> Void in
            })
        }
        else {
            self.isClosed = true
            UIView.animateWithDuration(0.3,  animations: { () -> Void in
                self.layer.transform = CATransform3DIdentity
                self.closeButton.layer.transform = CATransform3DIdentity
                switch orientation {
                case .Horizontal:
                    self.frame.size.width = 60
                    for (button, _) in self.horizontalButtons {
                        button.layer.transform = CATransform3DIdentity
                    }
                case .Vertical:
                    self.frame.size.height = 60
                    for (button, _) in self.verticalButtons {
                        button.layer.transform = CATransform3DIdentity
                    }
                case .None:
                    break
                }
                
                
                }, completion: { (finished) -> Void in
                    self.openOrientation = ABOrientation.None
            })
        }
    }
    
    public func close(completion:(() -> Void)?, sender : UIButton?) {
        self.isClosed = true
        UIView.animateWithDuration(0.3,  animations: { () -> Void in
            self.layer.transform = CATransform3DIdentity
            self.closeButton.layer.transform = CATransform3DIdentity
            
            self.frame.size.width = 60
            for (button, _) in self.horizontalButtons {
                if sender != button {
                    button.layer.transform = CATransform3DIdentity
                }
            }
            
            self.frame.size.height = 60
            for (button, _) in self.verticalButtons {
                                if sender != button {
                                    button.layer.transform = CATransform3DIdentity
                }
            }
            
            
            }, completion: { (finished) -> Void in
                if finished {
                    if let b = sender {
                         UIView.animateWithDuration(0.3,  animations: { () -> Void in
                            b.layer.transform = CATransform3DIdentity
                            },completion : { (finished)-> Void in
                            
                            })
                    }
                    if let complete = completion {
                        complete()
                    }
                }
        })
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init(orientation : ABOrientation, borderColor:UIColor?, backColor: UIColor?) {
        
        var frame : CGRect = CGRectZero
        
        frame.size.width = 60
        frame.size.height = 60
        
        self.init(frame: frame)
        let fr = CGRect(x: 8,y: 8,width: 44,height: 44)
        
        closeButton.frame = fr
        closeButton.tag = -1
        
        closeButton.circle()
        if let col = borderColor {
            self.borderColor = col
        }
        
        if let backCol = backColor {
            self.backColor = backCol
        }
        closeButton.border(self.borderColor,width: 1.0)
        closeButton.addTarget(self, action: "buttonTouched:" , forControlEvents: UIControlEvents.TouchUpInside)
        
        closeButton.setImage(UIImage(named: "addIcon", inBundle: NSBundle(forClass: ABExpendableButton.self), compatibleWithTraitCollection: nil), forState:UIControlState.Normal)
        closeButton.backgroundColor = self.backColor
        self.addSubview(closeButton)
        self.userInteractionEnabled  = true
        self.mainOrientation = orientation
        
    }
}

// MARK: - Color Button
extension ABExpendableButton {

    public func addVerticalButton (buttons:Dictionary<UIColor, (sender:UIButton) -> Void>) -> Void {
        for (key, _) in self.verticalButtons {
            key.removeFromSuperview()
        }
        self.verticalButtons.removeAll(keepCapacity: false)
        let fr = CGRect(x: 8,y: 8,width: 44,height: 44)
        for (key, value) in buttons {
            let button = UIButton(frame: fr)
            button.backgroundColor = key
            button.addTarget(self, action: "buttonTouched:" , forControlEvents: UIControlEvents.TouchUpInside)
            button.circle()
            button.border(UIColor.blackColor(),width: 1.0)
            switch verticaleDirection {
            case .Up :
                button.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin , UIViewAutoresizing.FlexibleTopMargin]
            default :
                break
           //     fatalError("No direction that's weird")
            }
            self.verticalButtons.updateValue(value, forKey: button)
            self.addSubview(button)

        }
        self.bringSubviewToFront(self.viewWithTag(-1)!)
    }


    public func addHorizontalButton (buttons:Dictionary<UIColor, (sender:UIButton) -> Void>) -> Void {
        for (key, _) in self.horizontalButtons {
            key.removeFromSuperview()
        }
        self.horizontalButtons.removeAll(keepCapacity: false)
        let fr = CGRect(x: 8,y: 8,width: 44,height: 44)
        for (key, value) in buttons {
            let button = UIButton(frame: fr)
            button.backgroundColor = key
            button.addTarget(self, action: "buttonTouched:" , forControlEvents: UIControlEvents.TouchUpInside)
            button.circle()
            button.border(self.borderColor,width: 1.0)
            self.horizontalButtons.updateValue(value, forKey: button)
            switch horizontalDirection {
            case .Left :
                button.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin]
            case .Right :
                button.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin]
            default :
                break
            }
            self.addSubview(button)

        }
        self.bringSubviewToFront(self.viewWithTag(-1)!)
    }
}
