//
//  AppDelegate.swift
//  Mentor
//
//  Created by Alexandre on 11/10/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit
import ABUIKit
import Fabric
import Crashlytics
import ABModel
import CloudKit
import Firebase

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var debugView:DebugConsoleView!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FIRApp.configure()
        Fabric.with([Crashlytics.self])
        
        if let window = self.window {
//            let vc = StoryboardScene.OnBoarding.initialViewController()
//            window.rootViewController = vc
//        
 
            CloudKitManager.availability({ (available, alert) in
                if available {
                    if CloudKitManager.userAlreadyConnectThisDevice() {
                        Answers.logLoginWithMethod("Login", success: true, customAttributes: nil)
                        User.getCurrentUser({ (user, error) -> () in
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                let vc = StoryboardScene.Main.initialViewController()
                                window.rootViewController = vc
                            })
                        })
                    }
                    else {
                        User.getCurrentUser({ (user, error) -> () in
                            guard let user = user else {
                                Answers.logSignUpWithMethod("Error", success: NSNumber(bool: true), customAttributes: nil)
                                let alert = UIAlertController(title: "An error occured", message: "please restart DraftLink", preferredStyle: UIAlertControllerStyle.Alert)
                                if let currentVC = window.rootViewController {
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                        currentVC.presentViewController(alert, animated: true, completion: nil)
                                    })
                                }
                                return
                            }
                            if user.teams.count == 0 {
                                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                    Answers.logSignUpWithMethod("New user", success: true, customAttributes: nil)
                                    let vc = StoryboardScene.OnBoarding.initialViewController()
                                    window.rootViewController = vc
                                })
                            }
                            else {
                                Answers.logLoginWithMethod("New device", success: true, customAttributes: nil)
                                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                    let vc = StoryboardScene.Main.initialViewController()
                                    window.rootViewController = vc
                                })
                            }
                        })
                    }
                }
                else {
                    if let currentVC = window.rootViewController {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            currentVC.presentViewController(alert!, animated: true, completion: nil)
                        })
                    }
                }
            })
        }
 
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}
