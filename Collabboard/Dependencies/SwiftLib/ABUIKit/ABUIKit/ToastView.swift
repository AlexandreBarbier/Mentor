//
//  ToastView.swift
//  ABUIKit
//
//  Created by Alexandre Barbier on 25/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

public let vkToastViewTag = 1000

open class ToastView : UIView {
    
    open var hideColor = UIColor.black.withAlphaComponent(0.6)
    fileprivate var firstX : CGFloat = 0
    fileprivate var firstY : CGFloat = 0
    fileprivate var swipeIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 6))
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate class func initToastView() -> ToastView {
        let view = UIViewController(nibName:"ToastView", bundle:Bundle(for:self)).view as! ToastView
        view.frame = view.frame.offsetBy(dx: 0, dy: -5)
        var fr = view.frame
        fr.size.width = UIApplication.shared.keyWindow!.frame.size.width
        if (!UIApplication.shared.isStatusBarHidden) {
            fr.size.height += 22
        }
        view.frame = fr
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        view.tag = vkToastViewTag
        let swipe = UIPanGestureRecognizer(target: view, action:#selector(ToastView.panGesture(_:)))
        var swipeCenter = view.center
        swipeCenter.y = view.frame.size.height - 8 - (view.swipeIndicator.frame.size.height / 2)
        view.swipeIndicator.rounded()
        view.swipeIndicator.center = swipeCenter
        view.swipeIndicator.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
        view.swipeIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.addSubview(view.swipeIndicator)
        view.addGestureRecognizer(swipe)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        return view
    }
    
    open class func initToastView(_ message:String,
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
    
    open func panGesture(_ pan:UIPanGestureRecognizer) -> Void {
        var translatedPoint = pan.translation(in: self)
        if (pan.state == UIGestureRecognizerState.began) {
            self.firstX = pan.view!.center.x
            self.firstY = pan.view!.center.y
        }

        translatedPoint = CGPoint(x: self.firstX , y: self.firstY + translatedPoint.y)
        if (translatedPoint.y <= self.firstY) {
            let k = (translatedPoint.y / self.firstY)
            self.swipeIndicator.layer.transform = CATransform3DMakeScale(k, k, k)
            self.alpha = k
            pan.view!.center = translatedPoint
        }
        if (pan.state == UIGestureRecognizerState.ended) {
            if (pan.view!.frame.origin.y < -(pan.view!.frame.size.height / 3)) {
                self.removeFromWindow()
            }
            else {
                let time = Double((self.firstY - pan.view!.center.y) / (0.7 * self.frame.size.height))
                UIView.animate(withDuration: time, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: { () -> Void in
                        self.alpha = 1.0
                        self.swipeIndicator.layer.transform = CATransform3DIdentity
                        pan.view!.center = CGPoint(x: self.firstX, y: self.firstY)
                    }, completion: { (finish:Bool) -> Void in
                    
                })

            }
        }
        
    }
    
    open func show() -> Void {
        let window = UIApplication.shared.keyWindow!
        let view = window.viewWithTag(vkToastViewTag)
        if (view != nil)
        {
            view?.removeFromSuperview()
        }
        window.addSubview(self)
        window.bringSubview(toFront: self)
    }
    
    
    
    override open func willMove(toWindow newWindow: UIWindow?) {
        if (newWindow != nil) {
            super.willMove(toWindow: newWindow)
            self.transform = CGAffineTransform(translationX: 0, y: -self.frame.size.height)
        }
    }
    
    fileprivate func removeFromWindow() -> Void {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.backgroundColor = self.hideColor
            }, completion: { (finish:Bool) -> Void in
                if (finish)
                {
                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: { () -> Void in
                        self.transform = CGAffineTransform(translationX: 0, y: -self.frame.size.height)
                        }, completion: { (finish:Bool) -> Void in
                        if (finish)
                        {
                            self.removeFromSuperview()
                        }
                    })
                }
        }) 
    }

    override open func  didMoveToWindow() {
        if (self.window != nil)
        {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.transform = CGAffineTransform.identity
                }, completion: { (finish:Bool) -> Void in
                    if (finish)
                    {
                        //super.didMoveToWindow()
                    }
            })
        }
    }
}
