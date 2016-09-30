//
//  RoundedView.swift
//  ABUIKit
//
//  Created by Alexandre Barbier on 25/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

extension UIView {
    
    public func rounded(_ radius:CGFloat? = nil) -> Void {
        if let radius = radius {
            self.layer.cornerRadius = radius
        }
        else {
            self.layer.cornerRadius = self.frame.size.height / 2
        }
        self.layer.masksToBounds = true
    }
    
    public func circle() -> Void {
       self.rounded()
    }
    
    public func removeRoundCorner() {
        self.layer.mask = nil
    }

    public func roundedBottom(_ radius:CGFloat) -> Void {
        let bottomShape = CAShapeLayer(layer:self.layer)
        bottomShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [UIRectCorner.bottomRight , UIRectCorner.bottomLeft] , cornerRadii: CGSize(width: radius, height: radius)).cgPath
        self.layer.mask = bottomShape
        self.layer.masksToBounds = true
    }
    
    public func roundedTop(_ radius:CGFloat) -> Void {
        let bottomShape = CAShapeLayer(layer:self.layer)
        bottomShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [UIRectCorner.topRight , UIRectCorner.topLeft] , cornerRadii: CGSize(width: radius, height: radius)).cgPath
        self.layer.mask = bottomShape
        self.layer.masksToBounds = true
    }
    
    public func roundedLeft(_ radius:CGFloat) -> Void {
        let bottomShape = CAShapeLayer(layer:self.layer)
        bottomShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [UIRectCorner.topLeft , UIRectCorner.bottomLeft] , cornerRadii: CGSize(width: radius, height: radius)).cgPath
        self.layer.mask = bottomShape
        self.layer.masksToBounds = true
    }
    
    public func roundedRight(_ radius:CGFloat) -> Void {
        let bottomShape = CAShapeLayer(layer:self.layer)
        bottomShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [UIRectCorner.topRight , UIRectCorner.bottomRight] , cornerRadii: CGSize(width: radius, height: radius)).cgPath
        self.layer.mask = bottomShape
        self.layer.masksToBounds = true
    }
    
   public func border(_ color:UIColor, width : CGFloat) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
}
