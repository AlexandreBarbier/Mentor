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
    var debugView: DebugConsoleView!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        Fabric.with([Crashlytics.self])
        
        if let window = self.window,
            let rootVC = window.rootViewController,
            let imgView = rootVC.view.viewWithTag(1) {
            
            let ending = { (vc:UIViewController, animated:Bool) in
                DispatchQueue.main.async {
                    if animated {
                        UIView.animate(withDuration: 0.3, animations: {
                            imgView.layer.transform = CATransform3DMakeTranslation(0, -115, 0)
                            }, completion: { (finished) in
                                if finished {
                                    window.rootViewController = vc
                                }
                        })
                    }
                    else {
                        window.rootViewController = vc
                    }
                }
            }
            
            CloudKitManager.availability({ (available, alert) in
                if available {
                    if CloudKitManager.userAlreadyConnectThisDevice() {
                        Answers.logLogin(withMethod: "Login", success: true, customAttributes: nil)
                        User.getCurrentUser({ (user, error) -> () in
                            ending(StoryboardScene.Main.initialViewController(), false)
                        })
                    }
                    else {
                        User.getCurrentUser({ (user, error) -> () in
                            guard let user = user else {
                                Answers.logSignUp(withMethod: "Error", success: NSNumber(value: true), customAttributes: nil)
                                let alert = UIAlertController(title: "An error occured", message: "please restart DraftLink", preferredStyle: UIAlertControllerStyle.alert)
                                
                                OperationQueue.main.addOperation({ () -> Void in
                                    rootVC.present(alert, animated: true, completion: nil)
                                })
                                return
                            }
                            let tuple = user.teams.count == 0 ? (method:"New user", animated:true) : (method:"New device", animated:false)
                            Answers.logSignUp(withMethod: tuple.method, success: true, customAttributes: nil)
                            ending(StoryboardScene.Main.initialViewController(), tuple.animated)
                        })
                    }
                }
                else {
                    if let alert = alert {
                        OperationQueue.main.addOperation({ () -> Void in
                            rootVC.present(alert, animated: true, completion: nil)
                        })
                    }
                }
            })
        }
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}
