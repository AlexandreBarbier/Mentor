//
//  ToastView.swift
//  ABUIKit
//
//  Created by Alexandre Barbier on 25/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

public let vkToastViewTag = 1000

public class ToastView : UIView {
    
    public var hideColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
    private var firstX : CGFloat = 0
    private var firstY : CGFloat = 0
    private var swipeIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 6))
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private class func initToastView() -> ToastView {
        let view = UIViewController(nibName:"ToastView", bundle:NSBundle(forClass:self)).view as! ToastView
        view.frame = CGRectOffset(view.frame, 0, -5)
        var fr = view.frame
        fr.size.width = UIApplication.sharedApplication().keyWindow!.frame.size.width
        if (!UIApplication.sharedApplication().statusBarHidden) {
            fr.size.height += 22
        }
        view.frame = fr
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        view.tag = vkToastViewTag
        let swipe = UIPanGestureRecognizer(target: view, action:#selector(ToastView.panGesture(_:)))
        var swipeCenter = view.center
        swipeCenter.y = view.frame.size.height - 8 - (view.swipeIndicator.frame.size.height / 2)
        view.swipeIndicator.rounded()
        view.swipeIndicator.center = swipeCenter
        view.swipeIndicator.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin]
        view.swipeIndicator.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        view.addSubview(view.swipeIndicator)
        view.addGestureRecognizer(swipe)
        view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        return view
    }
    
    public class func initToastView(message:String,
        iconUrl:String,
        textColor:UIColor,
        backgroundColor:UIColor,
        hideColor:UIColor) -> ToastView
    {
        let toast = ToastView.initToastView()
        toast.messageLabel.text = message
        toast.messageLabel.textColor = textColor
        toast.hideColor = hideColor
        toast.backgroundColor = backgroundColor
        
        return toast

    }
    
    public func panGesture(pan:UIPanGestureRecognizer) -> Void {
        var translatedPoint = pan.translationInView(self)
        if (pan.state == UIGestureRecognizerState.Began) {
            self.firstX = pan.view!.center.x
            self.firstY = pan.view!.center.y
        }

        translatedPoint = CGPointMake(self.firstX , self.firstY + translatedPoint.y)
        if (translatedPoint.y <= self.firstY) {
            let k = (translatedPoint.y / self.firstY)
            self.swipeIndicator.layer.transform = CATransform3DMakeScale(k, k, k)
            self.alpha = k
            pan.view!.center = translatedPoint
        }
        if (pan.state == UIGestureRecognizerState.Ended) {
            if (pan.view!.frame.origin.y < -(pan.view!.frame.size.height / 3)) {
                self.removeFromWindow()
            }
            else {
                let time = Double((self.firstY - pan.view!.center.y) / (0.7 * self.frame.size.height))
                UIView.animateWithDuration(time, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: { () -> Void in
                        self.alpha = 1.0
                        self.swipeIndicator.layer.transform = CATransform3DIdentity
                        pan.view!.center = CGPoint(x: self.firstX, y: self.firstY)
                    }, completion: { (finish:Bool) -> Void in
                    
                })

            }
        }
        
    }
    
    public func show() -> Void {
        let window = UIApplication.sharedApplication().keyWindow!
        let view = window.viewWithTag(vkToastViewTag)
        if (view != nil)
        {
            view?.removeFromSuperview()
        }
        window.addSubview(self)
        window.bringSubviewToFront(self)
    }
    
    
    
    override public func willMoveToWindow(newWindow: UIWindow?) {
        if (newWindow != nil) {
            super.willMoveToWindow(newWindow)
            self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height)
        }
    }
    
    private func removeFromWindow() -> Void {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.backgroundColor = self.hideColor
            }) { (finish:Bool) -> Void in
                if (finish)
                {
                    UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: { () -> Void in
                        self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height)
                        }, completion: { (finish:Bool) -> Void in
                        if (finish)
                        {
                            self.removeFromSuperview()
                        }
                    })
                }
        }
    }

    override public func  didMoveToWindow() {
        if (self.window != nil)
        {
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                }, completion: { (finish:Bool) -> Void in
                    if (finish)
                    {
                        //super.didMoveToWindow()
                    }
            })
        }
    }
}
