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
            drawableView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
            let pan = UIPanGestureRecognizer(target: drawableView, action: "panGesture:")
            pan.maximumNumberOfTouches = 1
            self.setNeedsLayout()
            pan.delegate = drawableView
            self.addGestureRecognizer(pan)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.panGestureRecognizer.minimumNumberOfTouches = 2
    }
}
