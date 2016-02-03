//
//  ImageWithUrl.swift
//  ABRequest
//
//  Created by Alexandre Barbier on 24/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit
private let _imageQueue_ = NSOperationQueue()

public extension UIImageView {
    
    public func setImageWithURL(url:NSURL?, placeholder:UIImage) {
        
        self.image = placeholder
        self.setImageWithUrl(url,withActivity: false)
    }
    
    public func setImageWithUrl(url:NSURL!, withActivity:Bool) {
        
        let activityIndicator = UIActivityIndicatorView(frame: self.frame)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        if withActivity {
            self.superview!.addSubview(activityIndicator)
            
            activityIndicator.hidesWhenStopped = true;
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        }
        _imageQueue_.name = "imageQueue"
        if url != nil {
            let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30)

            NSURLConnection.sendAsynchronousRequest(request, queue: _imageQueue_, completionHandler: {(response:NSURLResponse?, data:NSData?, error:NSError?) in
                NSOperationQueue.mainQueue().addOperationWithBlock(
                    { () -> Void in
                        if (error != nil)
                        {
                            return;
                        }
                        self.image = UIImage(data:data!)

                        if withActivity {
                            activityIndicator.stopAnimating()
                            activityIndicator.removeFromSuperview()
                        }
                })
                
                
            })
        }
    }
    
    public func setImageWithUrl(url:NSURL?, withActivity:Bool, completion:((success:Bool)->Void)?) {
        
        let activityIndicator = UIActivityIndicatorView(frame: self.frame)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        if withActivity {
            self.superview!.addSubview(activityIndicator)
            
            activityIndicator.hidesWhenStopped = true;
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        }
        _imageQueue_.name = "imageQueue"
        if url != nil {
            let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30)
            NSURLConnection.sendAsynchronousRequest(request, queue: _imageQueue_, completionHandler: {(response:NSURLResponse?, data:NSData?, error:NSError?) in
                NSOperationQueue.mainQueue().addOperationWithBlock(
                    { () -> Void in
                        if (error != nil)
                        {
                            if let comp = completion {
                                comp(success:false)
                            }
                            
                            return;
                        }
                        self.image = UIImage(data:data!)
                        if let comp = completion {
                            comp(success:true)
                        }
                        if withActivity {
                            activityIndicator.stopAnimating()
                            activityIndicator.removeFromSuperview()
                        }
                })
                
                
            })
        }
    }
}
//
//public extension UIImage {
//    
//    convenience init(url:NSURL) {
//        self.init()
//        _imageQueue_.qualityOfService = NSQualityOfService.UserInteractive
//        let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30)
//        NSURLConnection.sendAsynchronousRequest(request, queue: _imageQueue_, completionHandler: {(response:NSURLResponse?, data:NSData?, error:NSError?) in
//            NSOperationQueue.mainQueue().addOperationWithBlock(
//                { () -> Void in
//                    if (error != nil)
//                    {
//                        
//                        return;
//                    }
//                    self.init(data:data!)
//                    
//            })
//            
//            
//        })
//    }
//}
