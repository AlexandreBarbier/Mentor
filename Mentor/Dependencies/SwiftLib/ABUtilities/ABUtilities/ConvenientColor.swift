//
//  ConvenientColor.swift
//  ABUtilities
//
//  Created by Alexandre barbier on 24/09/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import UIKit

public extension UIColor {
    public convenience init(red:Int, green:Int, blue:Int) {
        var r = CGFloat(red)/255.0
        var g = CGFloat(green)/255.0
        var b = CGFloat(blue)/255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
}