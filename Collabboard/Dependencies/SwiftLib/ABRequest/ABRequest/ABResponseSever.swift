//
//  VServerObject.swift
//  RateMe
//
//  Created by Alexandre Barbier on 22/06/14.
//  Copyright (c) 2014 Poutsch. All rights reserved.
//

import UIKit

public class ABResponseObject: NSObject {
    public var status = 0
    public var meta = 0
    public var error:AnyObject?
    public var response:AnyObject?
    
    public override var description :String { get { return "ABResponseObject status : \(status) \nerror : \(error) \nresponse :\n<\n\(response)\n>\n"} }
    public override init() {
        super.init()
    }
    
    public init(dictionary:Dictionary<String, AnyObject>) {
        super.init()
        var finalDictionnary = dictionary
        for (key, value) in dictionary {
            if !self.respondsToSelector(Selector(key)) {
                let replacementKey = self.replaceKey(key)
                if replacementKey.isEmpty {
                    finalDictionnary.removeAtIndex(finalDictionnary.indexForKey(key)!)
                    
                }
                else {
                    finalDictionnary[replacementKey] = value;
                    finalDictionnary.removeAtIndex(finalDictionnary.indexForKey(key)!)
                    
                }
            }
        }
        self.setValuesForKeysWithDictionary(finalDictionnary)
    }
    
    public init(response:NSData!) {
        super.init()
        let error : NSError? = nil
        var dictionary:Dictionary<String, AnyObject>
        do {
            dictionary = try NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions.MutableLeaves ) as! Dictionary<String, AnyObject>
        }
        catch {
            dictionary = [:]
        }
        if error == nil {
            var finalDictionnary = dictionary
            for (key, value) in dictionary {
                if !self.respondsToSelector(Selector(key)) {
                    let replacementKey = self.replaceKey(key)
                    if replacementKey.isEmpty {
                        finalDictionnary.removeAtIndex(finalDictionnary.indexForKey(key)!)
                        
                    }
                    else {
                        finalDictionnary[replacementKey] = value;
                        finalDictionnary.removeAtIndex(finalDictionnary.indexForKey(key)!)
                        
                    }
                }
            }
            if finalDictionnary.count != 0 {
                self.setValuesForKeysWithDictionary(finalDictionnary)
            }
        }
    }
    
    public override func setValue(value: AnyObject!, forKey key: String)  {
        if (value != nil) {
            super.setValue(value, forKey: key)
        }
    }
    
    public func replaceKey(key:String) -> String {
        return "";
    }
}
