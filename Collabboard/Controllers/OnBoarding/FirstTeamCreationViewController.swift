//
//  FirstTeamCreationViewController.swift
//  Collabboard
//
//  Created by Alexandre barbier on 17/05/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class FirstTeamCreationViewController: UIViewController {

    @IBOutlet var backgroundView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var getStartedLabel: UILabel!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var projectTextView: DFTextField!
    @IBOutlet var teamTextView: DFTextField!
}

// MARK: - View lifecycle
extension FirstTeamCreationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sendSubviewToBack(backgroundView)
        
        getStartedLabel = {
            $0.textColor = UIColor.draftLinkBlueColor()
            $0.font = UIFont.Kalam(.Bold, size: 30)
            return $0
        }(getStartedLabel)
        
        descriptionLabel = {
            $0.textColor = UIColor.draftLinkDarkBlueColor()
            $0.font = UIFont.Roboto(.Regular, size: 24)
            return $0
        }(descriptionLabel)
        
        createButton = {
            $0.backgroundColor = UIColor.draftLinkBlueColor()
            $0.rounded(5)
            $0.tintColor = UIColor.whiteColor()
            return $0
        }(createButton)
        
        projectTextView = {
            $0.padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
            $0.setup(UIImage.Asset.Ic_project_mini.image, border: UIColor.draftLinkBlueColor(), innerColor: UIColor.draftLinkDarkBlueColor(),  cornerRadius: 5.0)
            return $0
        }(projectTextView)
        
        teamTextView = {
            $0.padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
            $0.setup(UIImage.Asset.Ic_team_mini.image, border: UIColor.draftLinkBlueColor(), innerColor: UIColor.draftLinkDarkBlueColor(), cornerRadius: 5.0)
            return $0
        }(teamTextView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension FirstTeamCreationViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == teamTextView {
            projectTextView.becomeFirstResponder()
        }
        else if teamTextView.text == "" {
            teamTextView.becomeFirstResponder()
        }
        else if projectTextView.text != "" {
            projectTextView.resignFirstResponder()
        }
        return false
    }
}

// MARK: - Navigation
extension FirstTeamCreationViewController {
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if let segueId = StoryboardSegue.OnBoarding(rawValue: identifier) {
            switch segueId {
            case .CreateTeamSegue:
                if projectTextView.text != "" && teamTextView.text != "" {
                    return true
                }
                return false
            default:
                break
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueId = StoryboardSegue.OnBoarding(rawValue: segue.identifier!) {
            switch segueId {
            case .CreateTeamSegue:
                let _ : UserConfigurationViewController = {
                    $0.teamName = teamTextView.text!
                    $0.projectName = projectTextView.text!
                    return $0
                } (segue.destinationViewController as! UserConfigurationViewController)
                break
            default:
                break
            }
        }
    }
}