//
//  UserTableViewCell.swift
//  Collabboard
//
//  Created by Alexandre barbier on 13/06/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var presenceIndicatorView: UIView!
    @IBOutlet var avatarView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        usernameLabel.font = UIFont.Roboto(.Regular, size: 17.0)
        avatarView.rounded()
        avatarView.image = avatarView.image?.imageWithRenderingMode(.AlwaysTemplate)
        presenceIndicatorView.rounded()
        presenceIndicatorView.backgroundColor = UIColor.redColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
