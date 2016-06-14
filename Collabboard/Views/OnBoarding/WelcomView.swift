//
//  WelcomView.swift
//  Collabboard
//
//  Created by Alexandre barbier on 28/05/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class WelcomView: UIView {
    @IBOutlet var welcomLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    static func instantiate() -> WelcomView {
        let welcomV : WelcomView = {
            $0.welcomLabel.textColor = UIColor.draftLinkDarkBlue()
            $0.welcomLabel.font = UIFont.Roboto(.Regular, size: 24)!
            $0.descriptionLabel.textColor = UIColor.draftLinkDarkBlue()
            $0.descriptionLabel.font = UIFont.Roboto(.Italic, size: 20)!
            return $0
        }(UIViewController(nibName: "WelcomView", bundle: nil).view as! WelcomView)
        
        return welcomV
    }
}
