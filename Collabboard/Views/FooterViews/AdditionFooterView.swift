//
//  AdditionFooterView.swift
//  Collabboard
//
//  Created by Alexandre barbier on 15/06/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit
import MessageUI

class AdditionFooterView: UIView {
    @IBOutlet var addButton: UIButton!
    @IBOutlet var titleLabel: UILabel!

    weak var delegate: UIViewController!
    enum FooterViewConfiguration: String {
        case Users, Team, Project
    }

    fileprivate var config: FooterViewConfiguration = .Users
}

// MARK: - View lifecycle
extension AdditionFooterView {
    class func instanciate(withConfiguration configuration: FooterViewConfiguration,
                           delegate: UIViewController) -> AdditionFooterView {
        let view: AdditionFooterView
        if let addFV = UINib(nibName: "AdditionFooterView", bundle: nil).instantiate(withOwner: nil, options: nil).first
            as? AdditionFooterView {
            view = {
                $0.delegate = delegate
                switch configuration {
                case .Users:
                    $0.titleLabel.text = "Invite users to your team"
                    break
                case .Project:
                    $0.titleLabel.text = "Create a new project"
                    break
                case .Team:
                    $0.titleLabel.text = "Create a new team"
                    break
                }
                $0.config = configuration
                return $0
            }(addFV)
        } else {
            view = AdditionFooterView()
        }
        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addButton.rounded()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AdditionFooterView.onAddTouch(_:)))
        addGestureRecognizer(tapGesture)
        addButton.backgroundColor = UIColor.draftLinkGrey
        titleLabel.font = UIFont.Roboto(.regular, size: 16)
    }
}

// MARK: - Actions
extension AdditionFooterView {

    @IBAction func onAddTouch(_ sender: AnyObject) {
        switch config {
        case .Users:
            self.delegate.showMailController(subject: "Invite your friends", body: "")
            break

        case .Project:
            if delegate.shouldPerformSegue(withIdentifier: StoryboardSegue.Main.projectCreationSegue.rawValue,
                                           sender: nil) {
                delegate.performSegue(withIdentifier: StoryboardSegue.Main.projectCreationSegue.rawValue,
                                      sender:nil)
            } else {
                let msg = "You cannot create a project in this team since you are not the administrator"
                let alert = UIAlertController(title: "Error",
                                              message: msg,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                delegate.present(alert, animated: true, completion: nil)
            }
            break
        case .Team:
            delegate.performSegue(withIdentifier: StoryboardSegue.Main.teamCreationSegue.rawValue, sender:nil)
            break
        }
    }
}
