//
//  ABRequest.swift
//  ABRequest
//
//  Created by Alexandre Barbier on 23/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

public enum HTTPResponseStatusCode : Int {
    case OK = 200
    case CREATED = 201
    case Accepted = 202
    case PartialInformation = 203
    case NoResponse = 204
    case Unauthorize = 401
    case NotFound = 404
    case ServerError = 500
    case badGateway = 502
    case timeout = 503

    case k = 504
    func simpleDescription () -> String {
        switch self {
        case .OK :
            return "\(self.rawValue) OK"
        case .CREATED :
            return "\(self.rawValue) Created"
        case .Accepted :
            return "\(self.rawValue) Accepted"
        case .PartialInformation :
            return "\(self.rawValue) Partial Information"
        case .NoResponse:
            return "\(self.rawValue) No Response"
        case .Unauthorize :
            return "\(self.rawValue) Unauthorize"
        case .NotFound:
            return "\(self.rawValue) Not Found"
        case .ServerError :
            return "\(self.rawValue) server error"
        case .timeout :
            return "\(self.rawValue) timeout"
        case .badGateway:
            return "\(self.rawValue) bad gateway"
        default :
            return "\(self.rawValue) unknown code"
        }
    }
}

public enum HTTPMethod : String {
    case GET = "GET"
    case PUT = "PUT"
    case POST = "POST"
    case DELETE = "DELETE"
}



public class ABRequest : NSObject {
    public static let sharedABRequest = ABRequest()
    private let getRequestQueue = NSOperationQueue()
    private let postRequestQueue = NSOperationQueue()
    private var getRequest = NSMutableURLRequest()
    private var deleteRequest = NSMutableURLRequest()
    private var putRequest = NSMutableURLRequest()
    private var postRequest = NSMutableURLRequest()
    private var postFormRequest = NSMutableURLRequest()
    public var defaultHeader = Dictionary<String,String>()
    public var defaultParam = Dictionary<String, AnyObject>()
    public var reachabilityManager = ABReachability()
    
    private override init () {
        super.init()
        reachabilityManager.startNotifier()
        getRequestQueue.name = "getRequestOperation_\(self.description)"
        postRequestQueue.name = "postRequestQueue_\(self.description)"
        getRequest.HTTPMethod = HTTPMethod.GET.rawValue
        putRequest.HTTPMethod = HTTPMethod.PUT.rawValue
        deleteRequest.HTTPMethod = HTTPMethod.DELETE.rawValue
        postRequest.HTTPMethod = HTTPMethod.POST.rawValue
        postFormRequest.HTTPMethod = HTTPMethod.POST.rawValue
        addHeaderField("application/json", headerField: "Content-Type")
        addHeaderField("application/json", headerField: "Accept")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "networkStatusChanged:", name: kReachabilityChangedNotification, object: nil)
    }
    
    public func networkStatusChanged (sender:AnyObject) {
        
    }
    
    public init(headers:Dictionary<String,String>) {
        super.init()
        reachabilityManager.startNotifier()
        getRequestQueue.name = "getRequestOperation_\(self.description)"
        postRequestQueue.name = "postRequestQueue_\(self.description)"
        getRequest.HTTPMethod = HTTPMethod.GET.rawValue
        putRequest.HTTPMethod = HTTPMethod.PUT.rawValue
        deleteRequest.HTTPMethod = HTTPMethod.DELETE.rawValue
        postRequest.HTTPMethod = HTTPMethod.POST.rawValue
        postFormRequest.HTTPMethod = HTTPMethod.POST.rawValue
        addHeaderField("application/json", headerField: "Content-Type")
        addHeaderField("application/json", headerField: "Accept")
        for (key,value) in headers
        {
            addHeaderField(value, headerField: key)
        }
    }
    
    private func addDefaultHeader(request:NSMutableURLRequest) {
        for (key, value): (String, String) in defaultHeader {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    public func addHeaderField(value:String, headerField:String) {
        self.defaultHeader.updateValue(value, forKey: headerField)
        
        addDefaultHeader(getRequest)
        addDefaultHeader(postRequest)
                addDefaultHeader(deleteRequest)
        addDefaultHeader(postFormRequest)
    }
    
    private func setDefaultHeader(header:Dictionary<String,String>) {
        defaultHeader = header;
    }
    
    private class func prepareRequest(request:NSMutableURLRequest, url:NSURL, param:Dictionary<String, AnyObject>?) {
        request.URL = url;
        if param != nil {
            var finalParams = param!
            sharedABRequest.addDefaultHeader(request)
            for (key, value): (String, AnyObject) in sharedABRequest.defaultParam {
                finalParams.updateValue(value, forKey: key)
            }
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(finalParams, options: [])
            } catch _ as NSError {

                request.HTTPBody = nil
            }
        }
    }
    
    public class func get(url:NSURL,
        param:Dictionary<String, AnyObject>?,
        success:(response:NSURLResponse!,
        data:NSData!)->Void,
        failure:(response:NSURLResponse?, error:NSError!)->Void)
    {
        sharedABRequest.getRequest.URL = url

        NSURLConnection.sendAsynchronousRequest(sharedABRequest.getRequest, queue: sharedABRequest.getRequestQueue) { (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            
            if error == nil
            {
                NSOperationQueue.mainQueue().addOperationWithBlock(
                    { () -> Void in
                        if (ABRequest.checkStatusCode(response) == HTTPResponseStatusCode.OK) {
                            success(response: response, data: data)
                        }
                        else {
                            
                            let err = NSError(domain: "ABRequest.get", code: ABRequest.checkStatusCode(response).rawValue, userInfo:  nil)
                            failure(response: response, error: err)
                        }
                })
            }
            else
            {
                NSOperationQueue.mainQueue().addOperationWithBlock(
                    { () -> Void in
                        
                        failure(response: response, error: error)
                })
            }
        }
    }
    
    public class func post(url:NSURL, param:Dictionary<String, AnyObject>? , success:(response:NSURLResponse!, data:NSData!)->Void, failure:(response:NSURLResponse!,error:NSError!)->Void) {
        prepareRequest(sharedABRequest.postRequest, url: url, param: param)
        
        NSURLConnection.sendAsynchronousRequest(sharedABRequest.postRequest, queue: sharedABRequest.postRequestQueue) { (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            if error == nil {
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if (ABRequest.checkStatusCode(response) == HTTPResponseStatusCode.OK ) {
                        success(response: response, data:data)
                    }
                    else {
                        let serverObject = ABResponseObject(response: data as NSData!)
                        let err = NSError(domain: "ABRequest.post", code: ABRequest.checkStatusCode(response).rawValue, userInfo: ["data":serverObject.error!])
                        failure(response: response, error: err)
                    }
                })
            }
            else {
                
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    failure(response: response, error: error)
                })
            }
        }
    }
    
    public class func postForm (url:NSURL, param:Dictionary<String, AnyObject>? , urlParam:Dictionary<String, String>, success:(response:NSURLResponse!, data:NSData!)->Void, failure:(response:NSURLResponse!,error:NSError!)->Void) {
        let boundary = "---XXalexandreXX---"
        let contentType = "image/jpeg"
        for (key, value) in urlParam {
            sharedABRequest.postFormRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        sharedABRequest.postFormRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        sharedABRequest.postFormRequest.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        let body = NSMutableData()
        _ = "\n\r\(boundary)\r\n"
        if let parameters = param {
            for (_, value) in parameters {
                if let val = value as? NSData {
                    body.appendData(val)
                }
            }
        }
        sharedABRequest.postFormRequest.HTTPBody = body
        
        // set the content-length
        let postLength = "\(body.length)"
        sharedABRequest.postFormRequest.URL = url
        sharedABRequest.postFormRequest.addValue(postLength,forHTTPHeaderField:"Content-Length")
        NSURLConnection.sendAsynchronousRequest(sharedABRequest.postFormRequest, queue: sharedABRequest.postRequestQueue) { (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            if error == nil {
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if (ABRequest.checkStatusCode(response) == HTTPResponseStatusCode.OK) {
                        success(response: response, data:data)
                    }
                    else {
                        let err = NSError(domain: "ABRequest.post", code: ABRequest.checkStatusCode(response).rawValue, userInfo: ["data":data!])
                        failure(response: response, error: err)
                    }
                })
            }
            else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    failure(response: response, error: error)
                })
            }
        }
    }
    
    private class func checkContentType(response:NSURLResponse!) -> Bool {
        if let httpResponse = response as? NSHTTPURLResponse {
            let contentType : AnyObject? = httpResponse.allHeaderFields["Content-Type"]
            if (contentType as! NSString).containsString("application/json") {
                return true
            }
        }
        return false
    }
    
    private class func checkStatusCode(response:NSURLResponse!) -> HTTPResponseStatusCode! {
        if let status = response.valueForKey("statusCode") as? Int {
            if  (status < 300)
            {
                return HTTPResponseStatusCode.OK
            }
            return HTTPResponseStatusCode(rawValue: status)
        }
        return HTTPResponseStatusCode.ServerError
    }
    
    public class func delete(url:NSURL, param:Dictionary<String, AnyObject>?, success:(response:NSURLResponse!, data:NSData!)->Void, failure:(response:NSURLResponse! , error:NSError!)->Void) {
        prepareRequest(sharedABRequest.deleteRequest, url: url, param: param)
        NSURLConnection.sendAsynchronousRequest(sharedABRequest.deleteRequest, queue: sharedABRequest.postRequestQueue) { (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            if error == nil {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if (ABRequest.checkStatusCode(response) == HTTPResponseStatusCode.OK) {
                        success(response: response, data:data)
                    }
                    else {
                        let err = NSError(domain: "ABRequest.delete", code: ABRequest.checkStatusCode(response).rawValue, userInfo: ["data":data!])
                        failure(response: response, error: err)
                    }
                })
            }
            else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    failure(response: response, error: error)
                })
            }
        }
    }
    
    public class func put(url:NSURL, param:Dictionary<String, AnyObject> , success:(response:NSURLResponse!, data:NSData!)->Void, failure:(response:NSURLResponse! , error:NSError!)->Void) {
        prepareRequest(sharedABRequest.putRequest, url: url, param: param)
        NSURLConnection.sendAsynchronousRequest(sharedABRequest.putRequest, queue: sharedABRequest.postRequestQueue) { (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            if error == nil {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if (ABRequest.checkStatusCode(response) == HTTPResponseStatusCode.OK) {
                        success(response: response, data:data)
                    }
                    else {
                        let err = NSError(domain: "ABRequest.put", code: ABRequest.checkStatusCode(response).rawValue, userInfo: ["data":data!])
                        failure(response: response, error: err)
                    }
                })
            }
            else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    failure(response: response, error: error)
                })
            }
        }
    }
    
    private func prepareRequest(request:NSMutableURLRequest, url:NSURL, param:Dictionary<String, AnyObject>?) {
        request.URL = url;

        var finalParams=param!
        self.addDefaultHeader(request)
        for (key, value): (String, AnyObject) in self.defaultParam {
            finalParams.updateValue(value, forKey: key)
        }
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(finalParams, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            debugPrint(error.description)
        }
    }
    
    public func get(url:NSURL,
        param:Dictionary<String, AnyObject>?,
        success:(response:NSURLResponse!,
        data:NSData!)->Void,
        failure:(response:NSURLResponse?, error:NSError!)->Void)
    {
        self.getRequest.URL = url
        NSURLConnection.sendAsynchronousRequest(self.getRequest, queue: self.getRequestQueue) { (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            
            if error == nil
            {
                NSOperationQueue.mainQueue().addOperationWithBlock(
                    { () -> Void in
                        if (ABRequest.checkStatusCode(response) == HTTPResponseStatusCode.OK) {
                            success(response: response, data: data)
                        }
                        else {
                            let err = NSError(domain: "ABRequest.get", code: ABRequest.checkStatusCode(response).rawValue, userInfo: ["data":data!])
                            failure(response: response, error: err)
                        }
                })
            }
            else
            {
                NSOperationQueue.mainQueue().addOperationWithBlock(
                    { () -> Void in
                        failure(response: response, error: error)
                })
            }
        }
    }
    
    public func post(url:NSURL, param:Dictionary<String, AnyObject>? , success:(response:NSURLResponse!, data:NSData!)->Void, failure:(response:NSURLResponse!, error:NSError!)->Void) {
        prepareRequest(self.postRequest, url: url, param: param)
        
        NSURLConnection.sendAsynchronousRequest(self.postRequest, queue: self.postRequestQueue) { (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            if error == nil {
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if (ABRequest.checkStatusCode(response) == HTTPResponseStatusCode.OK) {
                        success(response: response, data:data)
                    }
                    else {
                        let err = NSError(domain: "ABRequest.post", code: ABRequest.checkStatusCode(response).rawValue, userInfo: ["data":data!])
                        failure(response: response, error: err)
                    }
                })
            }
            else {
                
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    failure(response: response, error: error)
                })
            }
        }
    }
    
    public func postForm (url:NSURL, param:Dictionary<String, AnyObject>? , success:(response:NSURLResponse!, data:NSData!)->Void, failure:(response:NSURLResponse!,error:NSError!)->Void) {
        let boundary = "---XXalexandreXX---"
        let contentType = "image/jpeg"
        self.postFormRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        self.postFormRequest.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        let body = NSMutableData()
        _ = "\n\r\(boundary)\r\n"
        if let parameters = param {
            for (_, value) in parameters {
                if let val = value as? NSData {
                    body.appendData(val)
                }
            }
        }
        self.postFormRequest.HTTPBody = body
        let postLength = "\(body.length)"
        self.postFormRequest.URL = url
        self.postFormRequest.addValue(postLength,forHTTPHeaderField:"Content-Length")
        NSURLConnection.sendAsynchronousRequest(self.postFormRequest, queue: self.postRequestQueue) { (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            if error == nil {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if (ABRequest.checkStatusCode(response) == HTTPResponseStatusCode.OK) {
                        success(response: response, data:data)
                    }
                    else {
                        let err = NSError(domain: "ABRequest.post", code: ABRequest.checkStatusCode(response).rawValue, userInfo: ["data":data!])
                        failure(response: response, error: err)
                    }
                })
            }
            else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    failure(response: response, error: error)
                })
            }
        }
    }
    
    private func checkStatusCode(response:NSURLResponse!) -> HTTPResponseStatusCode! {
        if let status = response.valueForKey("statusCode") as? Int {
            if  (status < 300)
            {
                return HTTPResponseStatusCode.OK
            }
            return HTTPResponseStatusCode(rawValue: status)
        }
        return .ServerError
    }
    
    public func delete(url:NSURL, param:Dictionary<String, AnyObject>?, success:(response:NSURLResponse!, data:NSData!)->Void, failure:(response:NSURLResponse! , error:NSError!)->Void) {
        prepareRequest(self.deleteRequest, url: url, param: param)
        NSURLConnection.sendAsynchronousRequest(self.deleteRequest, queue: self.postRequestQueue) { (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            if error == nil {

                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if (ABRequest.checkStatusCode(response) == HTTPResponseStatusCode.OK) {
                        success(response: response, data:data)
                    }
                    else {
                        let err = NSError(domain: "ABRequest.delete", code: ABRequest.checkStatusCode(response).rawValue, userInfo: ["data":data!])
                        failure(response: response, error: err)
                    }
                })
            }
            else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    failure(response: response, error: error)
                })
            }
        }
    }
    
    public func put(url:NSURL, param:Dictionary<String, AnyObject>? , success:(response:NSURLResponse!, data:NSData!)->Void, failure:(response:NSURLResponse! , error:NSError!)->Void) {
        prepareRequest(self.putRequest, url: url, param: param)
        NSURLConnection.sendAsynchronousRequest(self.putRequest, queue: self.postRequestQueue) { (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            if error == nil {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if (ABRequest.checkStatusCode(response) == HTTPResponseStatusCode.OK) {
                        success(response: response, data:data)
                    }
                    else {
                        let err = NSError(domain: "ABRequest.put", code: ABRequest.checkStatusCode(response).rawValue, userInfo: ["data":data!])
                        failure(response: response, error: err)
                    }
                })
            }
            else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    failure(response: response, error: error)
                })
            }
        }
    }
}
