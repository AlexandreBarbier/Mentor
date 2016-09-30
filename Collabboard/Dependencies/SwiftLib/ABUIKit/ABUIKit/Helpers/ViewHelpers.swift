//
//  ViewHelpers.swift
//  ABUIKit
//
//  Created by Alexandre barbier on 09/05/15.
//  Copyright (c) 2015 abarbier. All rights reserved.
//

import UIKit

extension UIView {
    /**
    add an array of view
    
    :param: views views to add
    */
    public func addSubviews(_ views:[UIView]) {
        for view:UIView in views {
            self.addSubview(view)
        }
    }
}
