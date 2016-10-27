//
//  DFButton.swift
//  Collabboard
//
//  Created by Alexandre barbier on 18/06/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class DFButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        rounded(5.0)
        border(UIColor.draftLinkBlue, width: 2.0)
        tintColor = UIColor.draftLinkDarkBlue
    }

}
