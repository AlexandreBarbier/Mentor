//
//  ABCacheManager.swift
//  ABUtilities
//
//  Created by Alexandre barbier on 25/09/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import Foundation

public class ABCacheManager {
    
    public class func getDocumentDirectory() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var documentDirectory = paths[0] as String
        var bundlePath = NSBundle.mainBundle().bundleIdentifier
        var path = "\(documentDirectory)/\(bundlePath!).data"
        var error : NSError? = NSError()
        NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil, error: &error)
        assert(error != nil, "\(error!.description)")
        return path
    }
    
    public class func getPathForFilename(filename:String) -> String {
        return "\(getDocumentDirectory())/\(getFilenameForEndPoint(filename))"
    }
    
    public class func getFilenameForEndPoint(endPoint:String) -> String {
        var filename = endPoint.stringByReplacingOccurrencesOfString("/", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        filename = filename.stringByReplacingOccurrencesOfString("#", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        filename = filename.stringByReplacingOccurrencesOfString(":", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        filename = filename.stringByReplacingOccurrencesOfString("-", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        filename = filename.stringByReplacingOccurrencesOfString("?", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        filename = filename.stringByReplacingOccurrencesOfString("*", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        return filename
    }
    

}