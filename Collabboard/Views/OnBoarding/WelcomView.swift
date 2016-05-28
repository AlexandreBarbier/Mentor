//
//  WelcomView.swift
//  Collabboard
//
//  Created by Alexandre barbier on 28/05/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class WelcomView: UIView {
    
    static func instantiate() -> WelcomView {
        return UIViewController(nibName: "WelcomView", bundle: nil).view as! WelcomView
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
