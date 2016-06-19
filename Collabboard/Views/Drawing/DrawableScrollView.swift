//
//  DrawableScrollView.swift
//  Mentor
//
//  Created by Alexandre barbier on 16/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit

class DrawableScrollView: UIScrollView {
    
    var drawableView:DrawableView! {
        didSet {
            drawableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            let pan = UIPanGestureRecognizer(target: drawableView, action: #selector(DrawableView.panGesture(_:)))
            pan.maximumNumberOfTouches = 1
            setNeedsLayout()
            pan.delegate = drawableView
            addGestureRecognizer(pan)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        panGestureRecognizer.minimumNumberOfTouches = 2
    }
}
