//
//  VoicePanelButton.swift
//  VoicePannel
//
//  Created by Alexandre barbier on 02/12/14.
//  Copyright (c) 2014 Poutsch. All rights reserved.
//

import UIKit

public class VoicePanelButton: UIButton {
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = self.frame.height / 2
        self.titleLabel!.font = UIFont.VoiceMediumWithSize(20)
    }

    public override init() {
        super.init()
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = self.frame.height / 2
        self.titleLabel!.font = UIFont.VoiceMediumWithSize(20)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = self.frame.height / 2
        self.titleLabel!.font = UIFont.VoiceMediumWithSize(20)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = self.frame.height / 2
        self.titleLabel!.font = UIFont.VoiceMediumWithSize(20)
    }
    
    public override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.VoicePanelBackBlueColor().CGColor
        self.setTitleColor(UIColor.VoicePanelBackBlueColor(), forState: UIControlState.Normal)
    }
    
   public override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        self.backgroundColor = UIColor.clearColor()
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
}
