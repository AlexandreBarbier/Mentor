//
//  TransparentTextLabel.swift
//  ABUIKit
//
//  Created by Alexandre Barbier on 23/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

public class TransparentTextLabel : UILabel {
    @IBInspectable public var insetForText : CGFloat = 0.0

override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override public func drawTextInRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        self.textColor = UIColor.clearColor()
        if (CGColorGetAlpha(self.backgroundColor?.CGColor) > 0.99)
        {
            self.backgroundColor = self.backgroundColor?.colorWithAlphaComponent(0.99)
        }
        CGContextSetBlendMode(ctx, CGBlendMode.Copy)
        var finalRect = rect
        
        if (insetForText != 0.0) {
            finalRect.size.width = finalRect.width - CGFloat(insetForText * 2.0)
            finalRect.origin.x = finalRect.origin.x + insetForText
        }
        
        super.drawTextInRect(finalRect)
    }
}

