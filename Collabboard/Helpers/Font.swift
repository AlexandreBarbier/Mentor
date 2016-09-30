//
//  Font.swift
//  Collabboard
//
//  Created by Alexandre barbier on 29/05/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

extension UIFont {
    enum Weight: String {
        case Bold, BoldItalic,
            Light, LightItalic,
            Regular,
            Black, BlackItalic,
            Italic,
            Medium,
            MediumItalic,
            Thin, ThinItalic
    }
    
    static func Kalam(_ weight: Weight, size:CGFloat) -> UIFont? {
        return UIFont(name: "Kalam-\(weight.rawValue)", size: size)
    }
    
    static func Roboto(_ weight: Weight, size:CGFloat) -> UIFont? {
        return UIFont(name: "Roboto-\(weight.rawValue)", size: size)
    }
}
