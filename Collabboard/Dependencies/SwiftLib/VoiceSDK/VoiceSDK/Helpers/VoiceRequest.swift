//
//  VoiceRequest.swift
//  RateMe
//
//  Created by Alexandre Barbier on 07/06/14.
//  Copyright (c) 2014 Poutsch. All rights reserved.
//
let LOG_REQUEST = false
let API_VERSION:Int = 1
#if DEBUG
//let BASE_URL:String = "https://api.voicepolls.com/\(API_VERSION)/"
let BASE_URL: String = "http://dev.api.voice.ee/\(API_VERSION)/"
    #else
    let BASE_URL:String = "https://api.voicepolls.com/\(API_VERSION)/"
#endif

public let VOICE_APP_STORE_URL: String = "itms-apps://itunes.apple.com/app/id853871592"
public let REDEEM_URL:String = "https://voicepolls.com/redeem?access_token=\(VoiceRequest.getAuthToken()!)"
public let PANEL_SHARE_URL:String = "https://voicepolls.com/panel"
public let VOICE_CLIENT_ID:String = "mobile"

import UIKit
import ABRequest

public class VoiceRequest {
    
    public class func setAuthToken(token:String) {
        var saver = NSUserDefaults()
        saver.setObject(token, forKey: "voice_access_token")
        saver.synchronize()
    }
    
    public class func getAuthToken() -> String? {
        var saver = NSUserDefaults()
        return saver.stringForKey("voice_access_token")
    }
    
    public class func resetAuthToken() -> Void {
        var saver = NSUserDefaults()
        saver.removeObjectForKey("voice_access_token")
        saver.synchronize()
    }
    
    public class func initRequest() {
        sharedABRequest.defaultParam.updateValue(VOICE_CLIENT_ID, forKey: "client_id")
        let str = "CFBundleShortVersionString"
        sharedABRequest.addHeaderField("Voice (iPhone; iOS\(UIDevice.currentDevice().systemVersion); version  \(NSBundle.mainBundle().infoDictionary![str]); gzip)", headerField: "User-Agent")
        NSBundle.mainBundle().infoDictionary
    }
    
    public class func get(path:String,
        parameters:Dictionary<String, AnyObject>?,
        cached:Bool,
        requireAuth:Bool,
        completion:(local:Bool,
        success:Bool,
        object:AnyObject?,
        error: NSError?) -> Void) {
            //Hack for parameters
            var params = parameters
            var str = "\(BASE_URL)\(path)"
            
            if requireAuth {
                if let token = getAuthToken() as String! {
                    str += "?access_token=\(token)"
                    
                }
                else {
                    params = Dictionary<String, AnyObject>()
                    //     params!.updateValue(token, forKey: "access_token")
                    
                }
            }
            if let param = parameters {
                for (key, value) in param {
                    if value is String {
                        str += "&\(key)=\"\(value)\""
                    }
                    else {
                        str += "&\(key)=\(value)"
                    }
                }
            }
            var urlOpt = NSURL(string: str)
            if let url = urlOpt {
                ABRequest.get(url, param: params, success: { (response, data) -> Void in
                    var serverObject = ABResponseObject(response: data)
                    completion(local:false, success:true, object:serverObject.response, error:nil)
                    }) { (response, error) -> Void in
                        completion(local:false, success:false, object:nil, error:error)
                }
            }
            else {
                completion(local:false, success:false, object:nil, error:nil)
            }
    }
    
    public class func post(path:String,
        parameters:Dictionary<String, AnyObject>?,
        cached:Bool,
        requireAuth:Bool,
        completion:(local:Bool,
        success:Bool,
        object:AnyObject?,
        error: NSError?) -> Void) {
            var str = "\(BASE_URL)\(path)"
            var params = parameters
            
            if requireAuth {
                if let token = getAuthToken() {
                    str += "?access_token=\(token)"
                    if params != nil {
                        params!.updateValue(token, forKey: "access_token")
                    }
                    else {
                        params = Dictionary<String, AnyObject>()
                        params!.updateValue(token, forKey: "access_token")
                    }
                }
            }
            
            ABRequest.post(NSURL(string: str)!, param: parameters, success: { (response, data) -> Void in
                var serverObject = ABResponseObject(response: data)
                completion(local: false, success: true, object: serverObject.response, error: nil)
                }) { (response, error) -> Void in
                    var err : NSError? = error
                    completion(local: false, success: false, object: response, error: err)
            }
    }
    
}

