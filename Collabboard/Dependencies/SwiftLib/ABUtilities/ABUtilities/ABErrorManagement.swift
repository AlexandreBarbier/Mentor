//
//  ABErrorManagement.swift
//  ABUtilities
//
//  Created by Alexandre barbier on 25/09/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import UIKit

public extension NSError {
    
    public convenience init(className:String, code: Int, userInfo:[NSObject : AnyObject]?) {
        var bundlePath = NSBundle.mainBundle().bundleIdentifier
        self.init(domain: "\(bundlePath).\(className)", code: code, userInfo: userInfo)
        
    }
}