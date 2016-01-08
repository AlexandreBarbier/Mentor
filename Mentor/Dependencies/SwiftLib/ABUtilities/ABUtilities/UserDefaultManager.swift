//
//  UserDefaultSaver.swift
//  ABUtilities
//
//  Created by Alexandre barbier on 24/09/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import UIKit

let sharedUserDefaultManager = UserDefaultManager()

public class UserDefaultManager {
    
    lazy var userDefault = NSUserDefaults.standardUserDefaults()
    lazy var appGroupUserDefault = NSUserDefaults()
    
    var appGroup : String = "" {
        didSet {
            appGroupUserDefault = NSUserDefaults(suiteName: appGroup)
        }
    }

    public func saveUserParam(value:AnyObject!, key:String) {
        userDefault.setObject(value, forKey: key)
        userDefault.synchronize()
    }
    
    public func getUserParam(key:String) -> AnyObject? {
        return userDefault.objectForKey(key)
    }
    
    public func saveAppParam(value:AnyObject!, key:String) {
        if appGroup != "" {
            appGroupUserDefault.setObject(value, forKey: key)
            appGroupUserDefault.synchronize()
        }
        else {
            fatalError("Set sharedUserDefaultManager.appGroup to use this method")
        }
    }
    
    public func getAppParam(key:String) -> AnyObject? {
        if appGroup != "" {
            return appGroupUserDefault.objectForKey(key)
        }
        else {
            fatalError("Set sharedUserDefaultManager.appGroup to use this method")
        }
        
    }
    
    public init() {
        
    }
    
    
    
}