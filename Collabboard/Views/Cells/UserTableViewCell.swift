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
        
        usernameLabel.font = UIFont.Roboto(.regular, size: 17.0)
        avatarView.rounded()
        avatarView.image = avatarView.image?.withRenderingMode(.alwaysTemplate)
        presenceIndicatorView.rounded()
        presenceIndicatorView.backgroundColor = UIColor.red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
