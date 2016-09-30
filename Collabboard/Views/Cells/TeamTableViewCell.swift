//
//  TeamTableViewCell.swift
//  Collabboard
//
//  Created by Alexandre barbier on 09/06/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class TeamTableViewCell: UITableViewCell {
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tokenLabel: UILabel!
    @IBOutlet var teamNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
