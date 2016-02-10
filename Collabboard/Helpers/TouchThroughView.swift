//
//  TouchThroughView.swift
//  Collabboard
//
//  Created by Alexandre barbier on 10/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class TouchThroughView: UIView {

    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let v = super.hitTest(point, withEvent: event)
        if v == self {
            return nil
        }
        return v
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
