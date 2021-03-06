//
//  TeamCreationViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 12/01/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class TeamCreationViewController: UIViewController {

    @IBOutlet var projectNameTF: DFTextField!
    @IBOutlet var teamNameTF: DFTextField!
    @IBOutlet var userNameTF: DFTextField!

    fileprivate var colorController: ColorGenerationViewController!
    fileprivate var chosenColor: UIColor?

    var completion: ((_ team: Team, _ project: Project?) -> Void)?
    var showUser = false
}

// MARK: - View livecycle
extension TeamCreationViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        projectNameTF.delegate = self
        teamNameTF.delegate = self
        userNameTF.delegate = self
        teamNameTF.becomeFirstResponder()
        if !showUser {
            teamNameTF.becomeFirstResponder()
            userNameTF.isHidden = true
        }

        let padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        teamNameTF.padding = padding
        teamNameTF.setup(Asset.icTeamMini.image,
                         border: UIColor.draftLinkBlue,
                         innerColor: UIColor.draftLinkDarkBlue,
                         cornerRadius: 5)

        projectNameTF.padding = padding
        projectNameTF.setup(Asset.icProjectMini.image,
                            border: UIColor.draftLinkBlue,
                            innerColor: UIColor.draftLinkDarkBlue,
                            cornerRadius: 5)

        userNameTF.padding = padding
        userNameTF.setup(border: UIColor.draftLinkBlue, innerColor: UIColor.draftLinkDarkBlue, cornerRadius: 5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - Navigation
extension TeamCreationViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == StoryboardSegue.CreationStoryboard.colorSegue.rawValue,
            let colorController = segue.destination as? ColorGenerationViewController {
            colorController.delegate = self
            colorController.loadFromNil = true
        }
    }
}

// MARK: - TextField delegate
extension TeamCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.teamNameTF || textField == self.userNameTF {
            next!.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return false
    }
}

extension TeamCreationViewController: ColorGenerationViewControllerDelegate {
    func didSelectColor(_ color: UIColor, seed: CGFloat) {
        chosenColor = color
    }
}

// MARK: - Actions
extension TeamCreationViewController {
    @IBAction func createTouch(_ sender: AnyObject) {

        guard let teamName = self.teamNameTF.text, teamName != "" else {
            showAlert(title: "Empty team name", message: "please name your team")
            return
        }
        guard let projectName = self.projectNameTF.text,
            let chosenColor = chosenColor,
            projectName != "" else {
                showAlert(title: "Empty project name", message: "please name your first project")
                return
        }
        if self.showUser {
            guard let userName = self.userNameTF.text, !self.userNameTF.isHidden && userName != "" else {
                showAlert(title: "Empty username", message: "please choose a username")
                return
            }
            User.currentUser!.username = userName
        }

        Team.create(teamName,
                    color: chosenColor,
                    colorSeed: ColorGenerator.instance.currentSeed,
                    completion: { (_, team) -> Void in
            Project.create(projectName, team: team, completion: { (project, team) -> Void in
                OperationQueue.main.addOperation({ () -> Void in
                    User.currentUser!.addTeam(team,
                                              color: chosenColor,
                                              colorSeed: ColorGenerator.instance.currentSeed,
                                              completion: {
                        project.setLastOpenForTeam(team)
                        self.completion?(team, project)
                        let _ = self.navigationController?.popToRootViewController(animated: true)
                    })
                })
            })
        })
    }
}
