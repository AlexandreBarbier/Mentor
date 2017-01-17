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
        view.sendSubview(toBack: backgroundView)

        getStartedLabel = {
            $0?.textColor = UIColor.draftLinkBlue
            $0?.font = UIFont.Kalam(.bold, size: 30)
            return $0
        }(getStartedLabel)

        descriptionLabel = {
            $0?.textColor = UIColor.draftLinkDarkBlue
            $0?.font = UIFont.Roboto(.regular, size: 24)
            return $0
        }(descriptionLabel)

        createButton = {
            $0?.backgroundColor = UIColor.draftLinkBlue
            $0?.rounded(5)
            $0?.tintColor = UIColor.white
            return $0
        }(createButton)

        projectTextView = {
            $0?.padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
            $0?.setup(Asset.icProjectMini.image,
                      border: UIColor.draftLinkBlue,
                      innerColor: UIColor.draftLinkDarkBlue,
                      cornerRadius: 5.0)
            return $0
        }(projectTextView)

        teamTextView = {
            $0?.padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
            $0?.setup(Asset.icTeamMini.image,
                      border: UIColor.draftLinkBlue,
                      innerColor: UIColor.draftLinkDarkBlue,
                      cornerRadius: 5.0)
            return $0
        }(teamTextView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension FirstTeamCreationViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == teamTextView {
            projectTextView.becomeFirstResponder()
        } else if teamTextView.text == "" {
            teamTextView.becomeFirstResponder()
        } else if projectTextView.text != "" {
            projectTextView.resignFirstResponder()
        }
        return false
    }
}

// MARK: - Navigation
extension FirstTeamCreationViewController {

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let segueId = StoryboardSegue.OnBoarding(rawValue: identifier) {
            switch segueId {
            case .createTeamSegue:
                return projectTextView.text != "" && teamTextView.text != ""
            default:
                break
            }
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = StoryboardSegue.OnBoarding(rawValue: segue.identifier!) {
            switch segueId {
            case .createTeamSegue:
                if let controller = segue.destination as? UserConfigurationViewController {
                    let _ : UserConfigurationViewController = {
                        $0.teamName = teamTextView.text!
                        $0.projectName = projectTextView.text!
                        return $0
                    } (controller)
                }
                break
            default:
                break
            }
        }
    }
}
