//
//  ABCrashLog.swift
//  ABCrashLog
//
//  Created by Alexandre barbier on 22/11/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import Foundation

public let ABCrashLogger = ABCrashLog()

public class ABCrashLog: NSObject {
    var crashLogQueue = NSOperationQueue()
    
    override init() {
        super.init()
        crashLogQueue.name = "crashLogQueue"
        let unsafe = UnsafeMutablePointer<(NSException!) -> Void>.alloc(1)
        unsafe.initialize(HandleException)
        let cPointer = COpaquePointer(unsafe)
        let functionPointer = CFunctionPointer<(NSException!) -> Void>(cPointer)
        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var documentDirectory = paths[0] as! String
        var bundlePath = NSBundle.mainBundle().bundleIdentifier
        var path = "\(documentDirectory)/\(bundlePath!).error"
        NSSetUncaughtExceptionHandler(functionPointer)
        var error : NSError? = NSError()
        NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil, error: &error)
        var except = NSKeyedUnarchiver.unarchiveObjectWithFile("\(path)/crashlog.aberror") as? NSException
        if let exception = except {
            var request = NSURLRequest(URL: NSURL(string: "http://62.210.238.47:1337/crashlog/create?name=\(exception.name)&reason=\(exception.reason)")!)
            NSURLConnection.sendAsynchronousRequest(request, queue: crashLogQueue, completionHandler: { (response, data, error) -> Void in
                NSFileManager.defaultManager().removeItemAtPath("\(path)/crashlog.aberror", error: nil)
            })
        }
    }
    
    let HandleException:(exception:NSException!) -> Void = { (exception:NSException!) in

        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var documentDirectory = paths[0] as! String
        var bundlePath = NSBundle.mainBundle().bundleIdentifier
        var path = "\(documentDirectory)/\(bundlePath!).error"
        NSKeyedArchiver.archiveRootObject(exception, toFile: "\(path)/crashlog.aberror")
    }
    
    
}
