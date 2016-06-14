//
//  HighlightedButton.swift
//  ABUIKit
//
//  Created by Alexandre Barbier on 24/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

public class HighlightedButton : UIButton {
    @IBInspectable public var highlightedColor : UIColor {
        didSet {
            self.setTitleColor(highlightedColor, forState: UIControlState.Normal)
        }
    }
    @IBInspectable public var bgColor:UIColor {
        didSet {
            self.setTitleColor(bgColor, forState: UIControlState.Highlighted)
            self.backgroundColor = bgColor
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = bgColor
        self.setTitleColor(self.bgColor, forState: UIControlState.Highlighted)
        self.setTitleColor(self.highlightedColor, forState: UIControlState.Normal)
        
    }
    
    public override init(frame: CGRect) {
        highlightedColor = UIColor.whiteColor()
        bgColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        super.init(frame: frame)
        
        self.setTitleColor(self.bgColor, forState: UIControlState.Highlighted)
        self.setTitleColor(self.highlightedColor, forState: UIControlState.Normal)
        
    }
    public required init(coder aDecoder: NSCoder) {
        highlightedColor = UIColor.whiteColor()
        bgColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        super.init(coder: aDecoder)!
    }
    
    public override var highlighted : Bool {
        set {
            super.highlighted = newValue
            if (newValue) {
                self.backgroundColor = self.highlightedColor
            }
            else {
                self.backgroundColor = self.bgColor
            }
        }
        get {
            return super.highlighted
        }
    }
}
