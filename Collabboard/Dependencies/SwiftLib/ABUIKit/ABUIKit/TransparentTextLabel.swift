//
//  TransparentTextLabel.swift
//  ABUIKit
//
//  Created by Alexandre Barbier on 23/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

open class TransparentTextLabel : UILabel {
    @IBInspectable open var insetForText : CGFloat = 0.0

override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override open func drawText(in rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        self.textColor = UIColor.clear
		if let bgColor = backgroundColor {
			if bgColor.cgColor.alpha > CGFloat(0.99) {
				backgroundColor = bgColor.withAlphaComponent(0.99)
			}
		}
        ctx?.setBlendMode(CGBlendMode.copy)
        var finalRect = rect
        
        if (insetForText != 0.0) {
            finalRect.size.width = finalRect.width - CGFloat(insetForText * 2.0)
            finalRect.origin.x = finalRect.origin.x + insetForText
        }
        
        super.drawText(in: finalRect)
    }
}

