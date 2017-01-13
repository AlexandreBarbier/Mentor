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
            $0?.pageIndicatorTintColor = UIColor.draftLinkGrey
            $0?.currentPageIndicatorTintColor = UIColor.draftLinkBlue
            return $0
        }(pageControl)
        
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var frame = view.bounds
        
        let welcomView : WelcomView = {
            $0.frame = frame
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return $0
        }(WelcomView.instantiate())
       
        frame.origin.x = frame.width
        
        let getStartedView : GetStartedView = {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.frame = frame
            $0.skipButton.addTarget(self, action: #selector(OnboardingViewController.skip), for: .touchUpInside)
            return $0
        }(GetStartedView.instantiate())
        
        scrollView = {
            $0?.addSubview(welcomView)
            $0?.addSubview(getStartedView)
            $0?.contentSize = CGSize(width: 2 * ($0?.frame.width)!, height: ($0?.frame.height)!)
            return $0
        }(scrollView)
        
    }
    
    func skip() {
        performSegue(withIdentifier: StoryboardSegue.OnBoarding.skipSegue.rawValue, sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}

extension OnboardingViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / view.frame.width)
    }
}
