//
//  ProjectTableViewCell.swift
//  Collabboard
//
//  Created by Alexandre barbier on 09/06/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {
    static let identifier = "ProjectTableViewCell"

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var projectNameLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
