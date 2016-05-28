//
//  GetStartedView.swift
//  Collabboard
//
//  Created by Alexandre barbier on 28/05/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class GetStartedView: UIView {

    @IBOutlet var skipButton: UIButton!
    static func instantiate() -> GetStartedView {
        return UIViewController(nibName: "GetStartedView", bundle: nil).view as! GetStartedView
    }

}
