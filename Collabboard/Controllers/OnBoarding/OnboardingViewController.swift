//
//  OnboardingViewController.swift
//  Collabboard
//
//  Created by Alexandre barbier on 21/05/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
       

        // Do any additional setup after loading the view.
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frame = self.view.bounds
        let welcomView = WelcomView.instantiate()
        welcomView.frame = frame
        welcomView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        frame.origin.x = frame.width
        let getStartedView = GetStartedView.instantiate()
        getStartedView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        getStartedView.frame = frame
        getStartedView.skipButton.addTarget(self, action: #selector(OnboardingViewController.skip), forControlEvents: .TouchUpInside)
        scrollView.addSubview(welcomView)
        scrollView.addSubview(getStartedView)
        scrollView.pagingEnabled = true
        scrollView.contentSize = CGSize(width: 2 * scrollView.frame.width, height: scrollView.frame.height)
    }
    
    func skip() {
        self.performSegue(StoryboardSegue.OnBoarding.SkipSegue, sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
