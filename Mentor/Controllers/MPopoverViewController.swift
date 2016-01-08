//
//  MPopoverViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 14/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit

class MPopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func present(viewController:UIViewController, sourceFrame:CGRect, inNavigationController: UINavigationController? = nil, completion:((project:Project, team:Team)->Void)? = nil) {
        let popover : UIViewController = inNavigationController == nil ? self : inNavigationController!
        popover.modalPresentationStyle = .Popover
        popover.popoverPresentationController?.delegate = self
        popover.popoverPresentationController?.sourceView = viewController.view
        popover.popoverPresentationController?.sourceRect = sourceFrame
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                viewController.presentViewController(popover, animated: true, completion: nil)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}
