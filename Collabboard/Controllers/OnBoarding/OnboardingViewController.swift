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
        
        pageControl.pageIndicatorTintColor = UIColor.draftLinkGreyColor()
        pageControl.currentPageIndicatorTintColor = UIColor.draftLinkBlueColor()
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
        
        scrollView.addSubview(welcomView)
        scrollView.addSubview(getStartedView)
        scrollView.contentSize = CGSize(width: 2 * scrollView.frame.width, height: scrollView.frame.height)
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
