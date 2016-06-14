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
    @IBOutlet var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl = {
            $0.pageIndicatorTintColor = UIColor.draftLinkGreyColor()
            $0.currentPageIndicatorTintColor = UIColor.draftLinkBlueColor()
            return $0
        }(pageControl)
        
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var frame = self.view.bounds
        
        let welcomView : WelcomView = {
            $0.frame = frame
            $0.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            return $0
        }(WelcomView.instantiate())
       
        frame.origin.x = frame.width
        
        let getStartedView : GetStartedView = {
            $0.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            $0.frame = frame
            $0.skipButton.addTarget(self, action: #selector(OnboardingViewController.skip), forControlEvents: .TouchUpInside)
            return $0
        }(GetStartedView.instantiate())
        
        scrollView = {
            $0.addSubview(welcomView)
            $0.addSubview(getStartedView)
            $0.contentSize = CGSize(width: 2 * $0.frame.width, height: $0.frame.height)
            return $0
        }(scrollView)
        
    }
    
    func skip() {
        self.performSegue(StoryboardSegue.OnBoarding.SkipSegue, sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension OnboardingViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / view.frame.width)
    }
}