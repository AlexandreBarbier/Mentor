//
//  GetStartedView.swift
//  Collabboard
//
//  Created by Alexandre barbier on 28/05/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class GetStartedView: UIView {
    @IBOutlet var getStartedLabel: UILabel!
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var firstDescriptionLabel: UILabel!
    @IBOutlet var secondDescriptionLabel: UILabel!
    
    static func instantiate() -> GetStartedView {
        let textColor = UIColor.draftLinkDarkBlue
        let getSView : GetStartedView = {
            $0.getStartedLabel.textColor = UIColor.draftLinkBlue
            $0.getStartedLabel.font = UIFont.Kalam(.bold, size: 30)
            $0.subtitleLabel.textColor = textColor
            $0.subtitleLabel.font = UIFont.Roboto(.regular, size: 24)
            $0.firstDescriptionLabel.textColor = textColor
            $0.firstDescriptionLabel.font = UIFont.Roboto(.italic, size: 20)
            $0.secondDescriptionLabel.textColor = textColor
            $0.secondDescriptionLabel.font = UIFont.Roboto(.italic, size: 20)
            $0.skipButton.tintColor = textColor
            $0.skipButton.titleLabel?.font = UIFont.Roboto(.italic, size: 20)
          return $0
        }(UIViewController(nibName: "GetStartedView", bundle: nil).view as! GetStartedView)
        
        return getSView
    }
}
