//
//  ABReachability.swift
//  ABRequest
//
//  Created by Alexandre Barbier on 14/09/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import Foundation
import SystemConfiguration

public enum NetworkStatus : UInt32 {
    case NotReachable = 0
    case ReachableViaWiFi
    case ReachableViaWWAN
    public func simpleDescription () -> String {
        switch self {
        case .NotReachable :
            return "Not reachable"
        case .ReachableViaWiFi :
            return "Wifi"
        case .ReachableViaWWAN :
            return "Data"
        }
    }
}

public let kReachabilityChangedNotification = "kNetworkReachabilityChangedNotification"

public class ABReachability : NSObject {
    
    var reachability = SCNetworkReachabilityCreateWithName(nil, "www.apple.com".UTF8String)
    var networkQueue = NSOperationQueue()
    var timer = NSTimer()
    var canCheckStatus = true
    public var currentStatus = NetworkStatus.NotReachable
    public var networkStatusChangeBlock : ((status:NetworkStatus) -> Void)? = nil {
        didSet {
            if currentStatus == NetworkStatus.NotReachable {
                NSNotificationCenter.defaultCenter().postNotificationName(kReachabilityChangedNotification, object: nil)
                if self.networkStatusChangeBlock != nil {
                    self.networkStatusChangeBlock!(status:self.currentStatus)
                }
            }
        }
    }
    
    public func getNetworkStatus() -> NetworkStatus {
        var flag = SCNetworkReachabilityFlags.IsDirect
        let netStatus = SCNetworkReachabilityGetFlags(reachability!, &flag)
        if (netStatus) {
            return networkStatusForFlags(flag)
        }
        return NetworkStatus.NotReachable
    }
    
    public override init() {
        super.init()
        self.networkQueue.name = "ReachabilityQueue"
    }
    
    
    public func networkStatusForFlags(flags : SCNetworkReachabilityFlags) -> NetworkStatus
    {
        
        if (flags != SCNetworkReachabilityFlags.Reachable)
        {
            // The target host is not reachable.
            return NetworkStatus.NotReachable;
        }
        
        var returnValue = NetworkStatus.NotReachable
        
        if (flags != SCNetworkReachabilityFlags.IsWWAN)
        {
            /*
            If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
            */
            returnValue = NetworkStatus.ReachableViaWiFi;
        }
        
        if (((flags != SCNetworkReachabilityFlags.ConnectionOnDemand) ||
            (flags != SCNetworkReachabilityFlags.ConnectionOnTraffic)))
        {
            /*
            ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
            */
            
            if (flags == SCNetworkReachabilityFlags.InterventionRequired)
            {
                /*
                ... and no [user] intervention is needed...
                */
                returnValue = NetworkStatus.ReachableViaWiFi;
            }
        }
        
        if (flags == SCNetworkReachabilityFlags.IsWWAN)
        {
            /*
            ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
            */
            returnValue = NetworkStatus.ReachableViaWWAN;
        }
        
        return returnValue
    }
    
    public class func ReachabilityCallback (target:SCNetworkReachability! , flags:SCNetworkReachabilityFlags , info:  UnsafeMutablePointer<Void>) -> Void
    {
        // Post a notification to notify the client that the network reachability changed.
        NSNotificationCenter.defaultCenter().postNotificationName(kReachabilityChangedNotification, object: self)
    }
    
    public func startNotifier() -> Bool
    {
        currentStatus = getNetworkStatus()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkStatus", userInfo: nil, repeats: true)
        return true;
    }
    
    public func checkStatus() -> Void {
        self.networkQueue.cancelAllOperations()
        if self.getNetworkStatus() != self.currentStatus && canCheckStatus {
            canCheckStatus = false
            self.networkQueue.addOperationWithBlock { () -> Void in
                self.currentStatus = self.getNetworkStatus()
                NSNotificationCenter.defaultCenter().postNotificationName(kReachabilityChangedNotification, object: nil)
                
                if self.networkStatusChangeBlock != nil {
                    self.networkStatusChangeBlock!(status:self.currentStatus)
                }
                self.canCheckStatus = true
            }
        }
    }
    
    public func stopNotifier()
    {
        if (reachability != nil)
        {
            self.timer.invalidate()
        }
    }
    
    
    
}