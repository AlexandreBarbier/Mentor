//
//  HighlightedButton.swift
//  ABUIKit
//
//  Created by Alexandre Barbier on 24/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

open class HighlightedButton : UIButton {
    @IBInspectable open var highlightedColor : UIColor {
        didSet {
            self.setTitleColor(highlightedColor, for: UIControlState())
        }
    }
    @IBInspectable open var bgColor:UIColor {
        didSet {
            self.setTitleColor(bgColor, for: UIControlState.highlighted)
            self.backgroundColor = bgColor
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = bgColor
        self.setTitleColor(self.bgColor, for: UIControlState.highlighted)
        self.setTitleColor(self.highlightedColor, for: UIControlState())
        
    }
    
    public override init(frame: CGRect) {
        highlightedColor = UIColor.white
        bgColor = UIColor.black.withAlphaComponent(0.9)
        super.init(frame: frame)
        
        self.setTitleColor(self.bgColor, for: UIControlState.highlighted)
        self.setTitleColor(self.highlightedColor, for: UIControlState())
        
    }
    public required init(coder aDecoder: NSCoder) {
        highlightedColor = UIColor.white
        bgColor = UIColor.black.withAlphaComponent(0.9)
        super.init(coder: aDecoder)!
    }
    
    open override var isHighlighted : Bool {
        set {
            super.isHighlighted = newValue
            if (newValue) {
                self.backgroundColor = self.highlightedColor
            }
            else {
                self.backgroundColor = self.bgColor
            }
        }
        get {
            return super.isHighlighted
        }
    }
}
