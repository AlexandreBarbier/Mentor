//
//  ParseHelper.swift
//  ABRequest
//
//  Created by Alexandre Barbier on 07/09/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import Foundation

let PARSE_BASE_URL = "https://api.parse.com/1/classes/"
let PARSE_FILE_BASE_URL = "https://api.parse.com/1/files/"

public class ParseHelper {
    private var requestManager : ABRequest
    
    public init () {
        requestManager = ABRequest(headers: [:])
    }
    
    public init(appId:String, APIKey:String) {
        requestManager = ABRequest(headers: ["X-Parse-Application-Id":appId,"X-Parse-REST-API-Key":APIKey])
        
    }
    
    public func GET(path:String, param: Dictionary<String,AnyObject>?, completion:(success:Bool,data:AnyObject!, error:NSError?) -> Void) -> Void {
        
        requestManager.get(NSURL(string: "\(PARSE_BASE_URL)" + path)!, param: param, success: { (response, data) -> Void in
            do {
                var result = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! Dictionary<String, AnyObject>
                completion(success: true, data: result["results"], error: nil)
            }
            catch {
                
            }
            
            
            }) { (response, error) -> Void in
                completion(success: false, data: nil, error: error)
        }
        
    }
    
    public func UploadImage(path:String, param: Dictionary<String, AnyObject>, completion:(success:Bool,data:AnyObject!, error:NSError?) -> Void) -> Void {
        requestManager.postForm(NSURL(string:"\(PARSE_FILE_BASE_URL)" + path)!, param: param, success: { (response, data) -> Void in
            do {
            let result = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! Dictionary<String, AnyObject>
            completion(success: true, data: result, error: nil)
            }
            catch {
                
            }
            }) { (response, error) -> Void in
                completion(success: false, data: nil, error: error)
        }
    }
    
    public  func PUT (path:String, param: Dictionary<String,AnyObject>?, completion:(success:Bool,data:AnyObject!, error:NSError?) -> Void) -> Void {
        requestManager.put(NSURL(string: "\(PARSE_BASE_URL)" + path)!, param: param!, success: { (response, data) -> Void in
            completion(success: true, data: nil, error: nil)
            }) { (response, error) -> Void in
                completion(success: false, data: nil, error: error)
        }
    }
    
    public func POST (path:String, param: Dictionary<String,AnyObject>?, completion:(success:Bool,data:AnyObject!, error:NSError?) -> Void) -> Void {
        requestManager.post(NSURL(string: "\(PARSE_BASE_URL)" + path)!, param: param, success: { (response, data) -> Void in
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! Dictionary<String, AnyObject>
                completion(success: true, data: result, error: nil)
            }
            catch {
                
            }
            }) { (response, error) -> Void in
                completion(success: false, data: nil, error: error)
        }
    }
}