//
//  ABExpendableButtons.swift
//  ABUIKit
//
//  Created by Alexandre barbier on 16/10/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

public enum ABOrientation : Int, CustomStringConvertible {
    case horizontal
    case vertical
    case none
    public var description : String {
        get {
            switch self {
            case .horizontal :
                return "Horizontal"
            case .vertical :
                return "Vertical"
            case .none :
                return "Both"
            }
            
        }
    }
}

public enum ABDirection : Int, CustomStringConvertible {
    case up
    case down
    case left
    case right
    public var description : String {
        get {
            switch self {
            case .up :
                return "Up"
            case .down :
                return "Down"
            case .left :
                return "Left"
            case .right :
                return "Right"
            }
        }
    }
}

open class ABExpendableButton: UIView {
    open var mainOrientation : ABOrientation = .horizontal
    open var changedOrientation : ((_ orientation:ABOrientation) -> Void)?
    open var openOrientation : ABOrientation = .horizontal {
        didSet {
            if let changeOr = self.changedOrientation {
                changeOr(openOrientation)
            }
        }
    }
    var borderColor = UIColor.black
    var backColor = UIColor.white

    open var verticaleDirection : ABDirection = .down {
        didSet {
            switch verticaleDirection {
            case .up :
                self.closeButton.autoresizingMask = [self.closeButton.autoresizingMask,UIViewAutoresizing.flexibleTopMargin]
                
            default :
                return
            }
        }
    }
    
    open var horizontalDirection : ABDirection = .left {
        didSet {
            switch horizontalDirection {
            case .left :
                self.closeButton.autoresizingMask = [self.closeButton.autoresizingMask,UIViewAutoresizing.flexibleLeftMargin]
            default :
                return
            }
        }
    }
    
    fileprivate var isClosed = true
    fileprivate var closeButton = UIButton()
    open var horizontalButtons : Dictionary<UIButton, (_ sender:UIButton) -> Void> = Dictionary<UIButton, (_ sender:UIButton) -> Void>()
    
    open func addHorizontalButton (_ buttons:Dictionary<String, (_ sender:UIButton) -> Void>) -> Void {
        for (key, _) in self.horizontalButtons {
            key.removeFromSuperview()
        }
        self.horizontalButtons.removeAll(keepingCapacity: false)
        let fr = CGRect(x: 8.0,y: 8.0, width: 44.0,height: 44.0)
        for (key, value) in buttons {
            let button = UIButton(frame: fr)
            button.setImage(UIImage(named: key), for: UIControlState())
            button.addTarget(self, action: #selector(ABExpendableButton.buttonTouched(_:)) , for: UIControlEvents.touchUpInside)
            button.circle()
            button.border(self.borderColor, width: UIScreen.main.scale)
            button.layer.masksToBounds = false
            button.backgroundColor = self.backColor
            self.horizontalButtons.updateValue(value, forKey: button)
            switch horizontalDirection {
            case .left :
                button.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleTopMargin]
                
            default :
                break
            //    fatalError("No direction that's weird")
            }
            self.addSubview(button)
            
        }
        self.bringSubview(toFront: self.viewWithTag(-1)!)
    }
    
    open var verticalButtons : Dictionary<UIButton, (_ sender:UIButton) -> Void> = Dictionary<UIButton, (_ sender:UIButton) -> Void>()
    
    open func addVerticalButton (_ buttons:Dictionary<String, (_ sender:UIButton) -> Void>) -> Void {
        for (key, _) in self.verticalButtons {
            key.removeFromSuperview()
        }
        self.verticalButtons.removeAll(keepingCapacity: false)
        let fr = CGRect(x: 8,y: 8,width: 44,height: 44)
        for (key, value) in buttons {
            let button = UIButton(frame: fr)
            button.setImage(UIImage(named: key), for: UIControlState())
            button.addTarget(self, action: #selector(ABExpendableButton.buttonTouched(_:)) , for: UIControlEvents.touchUpInside)
            button.circle()
            button.backgroundColor = self.backColor
            button.border(UIColor.black,width: 1.0)
            switch verticaleDirection {
            case .up :
                button.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin , UIViewAutoresizing.flexibleTopMargin]
            default :
                fatalError("No direction that's weird")
            }
            self.verticalButtons.updateValue(value, forKey: button)
            self.addSubview(button)
            
        }
        self.bringSubview(toFront: self.viewWithTag(-1)!)
    }
    
    open func openOtherOrientation() -> Void {
        if self.isClosed {
            switch self.mainOrientation {
            case .horizontal:
                self.openOrientation = .vertical
                self.animateButtons(.vertical)
            case .vertical :
                self.openOrientation = .horizontal
                self.animateButtons(.horizontal)
            default :
                fatalError("No orientation")
                
            }
            
        }
    }
    
    internal func buttonTouched(_ sender:UIButton) {
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
            t!(sender)
            
        }
    }

    
    internal func animateButtons(_ orientation: ABOrientation) {
        if self.isClosed {
            self.isClosed = false
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                
                var offset : CGFloat = 52.0
                switch orientation {
                case .horizontal:
                    switch self.horizontalDirection {
                    case .left :
                        offset = -52.0
                    case .right :
                        offset = 52.0
                    default :
                        offset = 0
                    }
                case .vertical :
                    switch self.verticaleDirection {
                    case .up :
                        offset = -52.0
                    case .down :
                        offset = 52.0
                    default :
                        offset = 0
                    }
                default :
                    fatalError("")
                }
                
                switch orientation {
                case .horizontal:
                    if self.horizontalDirection == .left {
                        self.layer.transform = CATransform3DMakeTranslation(-(self.superview!.frame.width - self.frame.width), 0, 0)
                    }
                    
                    self.frame.size.width = self.superview!.frame.size.width
                    for (button , _) in self.horizontalButtons {
                        button.layer.transform = CATransform3DMakeTranslation(offset, 0, 0)
                        
                        switch self.horizontalDirection {
                        case .left :
                            offset -= 52.0
                        case .right :
                            offset += 52.0
                        default :
                            offset = 0
                        }
                    }
                case .vertical:
                    if self.verticaleDirection == .up {
                        self.layer.transform = CATransform3DMakeTranslation(0, -(self.superview!.frame.height - self.frame.height), 0)
                    }
                    self.frame.size.height = self.superview!.frame.size.height
                    for (button , _) in self.verticalButtons {
                        
                        button.layer.transform = CATransform3DMakeTranslation(0, offset, 0)
                        switch self.verticaleDirection {
                        case .up :
                            offset -= 52.0
                        case .down :
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
            UIView.animate(withDuration: 0.3,  animations: { () -> Void in
                self.layer.transform = CATransform3DIdentity
                self.closeButton.layer.transform = CATransform3DIdentity
                switch orientation {
                case .horizontal:
                    self.frame.size.width = 60
                    for (button, _) in self.horizontalButtons {
                        button.layer.transform = CATransform3DIdentity
                    }
                case .vertical:
                    self.frame.size.height = 60
                    for (button, _) in self.verticalButtons {
                        button.layer.transform = CATransform3DIdentity
                    }
                case .none:
                    break
                }
                
                
                }, completion: { (finished) -> Void in
                    self.openOrientation = ABOrientation.none
            })
        }
    }
    
    open func close(_ completion:(() -> Void)?, sender : UIButton?) {
        self.isClosed = true
        UIView.animate(withDuration: 0.3,  animations: { () -> Void in
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
                         UIView.animate(withDuration: 0.3,  animations: { () -> Void in
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
        
        var frame : CGRect = CGRect.zero
        
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
        closeButton.addTarget(self, action: #selector(ABExpendableButton.buttonTouched(_:)) , for: UIControlEvents.touchUpInside)
        
        closeButton.setImage(UIImage(named: "addIcon", in: Bundle(for: ABExpendableButton.self), compatibleWith: nil), for:UIControlState())
        closeButton.backgroundColor = self.backColor
        self.addSubview(closeButton)
        self.isUserInteractionEnabled  = true
        self.mainOrientation = orientation
        
    }
}

// MARK: - Color Button
extension ABExpendableButton {

    public func addVerticalButton (_ buttons:Dictionary<UIColor, (_ sender:UIButton) -> Void>) -> Void {
        for (key, _) in self.verticalButtons {
            key.removeFromSuperview()
        }
        self.verticalButtons.removeAll(keepingCapacity: false)
        let fr = CGRect(x: 8,y: 8,width: 44,height: 44)
        for (key, value) in buttons {
            let button = UIButton(frame: fr)
            button.backgroundColor = key
            button.addTarget(self, action: #selector(ABExpendableButton.buttonTouched(_:)) , for: UIControlEvents.touchUpInside)
            button.circle()
            button.border(UIColor.black,width: 1.0)
            switch verticaleDirection {
            case .up :
                button.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin , UIViewAutoresizing.flexibleTopMargin]
            default :
                break
           //     fatalError("No direction that's weird")
            }
            self.verticalButtons.updateValue(value, forKey: button)
            self.addSubview(button)

        }
        self.bringSubview(toFront: self.viewWithTag(-1)!)
    }


    public func addHorizontalButton (_ buttons:Dictionary<UIColor, (_ sender:UIButton) -> Void>) -> Void {
        for (key, _) in self.horizontalButtons {
            key.removeFromSuperview()
        }
        self.horizontalButtons.removeAll(keepingCapacity: false)
        let fr = CGRect(x: 8,y: 8,width: 44,height: 44)
        for (key, value) in buttons {
            let button = UIButton(frame: fr)
            button.backgroundColor = key
            button.addTarget(self, action: #selector(ABExpendableButton.buttonTouched(_:)) , for: UIControlEvents.touchUpInside)
            button.circle()
            button.border(self.borderColor,width: 1.0)
            self.horizontalButtons.updateValue(value, forKey: button)
            switch horizontalDirection {
            case .left :
                button.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleTopMargin]
            case .right :
                button.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleTopMargin]
            default :
                break
            }
            self.addSubview(button)

        }
        self.bringSubview(toFront: self.viewWithTag(-1)!)
    }
}
