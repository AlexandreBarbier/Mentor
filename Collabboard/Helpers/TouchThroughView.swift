//
//  TouchThroughView.swift
//  Collabboard
//
//  Created by Alexandre barbier on 10/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class TouchThroughView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let v = super.hitTest(point, with: event)
        return v == self ? nil : v
    }
}
