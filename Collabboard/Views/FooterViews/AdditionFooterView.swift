//
//  AdditionFooterView.swift
//  Collabboard
//
//  Created by Alexandre barbier on 15/06/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class AdditionFooterView: UIView {
    @IBOutlet var addButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    weak var delegate : UIViewController!
    enum FooterViewConfiguration : String {
        case Users, Team, Project
    }
    
    private var config : FooterViewConfiguration = .Users
}

// MARK: - View lifecycle
extension AdditionFooterView {
    class func instanciate(withConfiguration configuration:FooterViewConfiguration, delegate:UIViewController) -> AdditionFooterView {
        let view : AdditionFooterView = {
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
        }(UINib(nibName: "AdditionFooterView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! AdditionFooterView)
        
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addButton.rounded()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AdditionFooterView.onAddTouch(_:)))
        addGestureRecognizer(tapGesture)
        addButton.backgroundColor = UIColor.draftLinkGrey()
        titleLabel.font = UIFont.Roboto(.Regular, size: 16)
    }

}

// MARK: - Actions
extension AdditionFooterView {
    
    @IBAction func onAddTouch(sender: AnyObject) {
        switch config {
        case .Users:
            
            break
        case .Project:
            if delegate.shouldPerformSegueWithIdentifier(StoryboardSegue.Main.ProjectCreationSegue.rawValue, sender: nil) {
                delegate.performSegue(StoryboardSegue.Main.ProjectCreationSegue, sender:nil)
            }
            else {
                    //TODO: alert user
                let alert = UIAlertController(title: "Error", message: "You cannot create a project in this team since you are not the administrator", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                delegate.presentViewController(alert, animated: true, completion: nil)
            }
            break
        case .Team:
            delegate.performSegue(StoryboardSegue.Main.TeamCreationSegue, sender:nil)
            break
        }
    }
}
