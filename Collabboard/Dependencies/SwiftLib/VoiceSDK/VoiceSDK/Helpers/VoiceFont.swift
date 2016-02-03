//
//  VoiceFont.swift
//  VoiceSDK
//
//  Created by Alexandre barbier on 26/11/14.
//  Copyright (c) 2014 Poutsch. All rights reserved.
//

import UIKit

public extension UIFont {
    public class func VoiceRegularWithSize(_size:Float) -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: CGFloat(_size))!
    }
    public class func VoiceMediumWithSize(_size:Float) -> UIFont {
        return UIFont(name: "AvenirNext-Medium", size: CGFloat(_size))!
    }
}


extension UIColor {
    
    class func RGB(r:Float,g:Float,b:Float) -> UIColor {
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
    
    class func VoicePanelBackBlueColor() -> UIColor {
        //090c20
        return RGB(r: 0x09, g: 0x0c , b: 0x20)
    }
    
    class func VoicePanelBlueColor() -> UIColor {
        //03a9f4
        return RGB(r: 0x03, g: 0xa9, b: 0xf4)
    }
    
    class func VoicePanelErrorColor() -> UIColor {
        return RGB(r: 0xfe, g: 0x5d, b: 0x57)
    }
}