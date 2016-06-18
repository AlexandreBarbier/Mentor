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
    
    private var colorController : ColorGenerationViewController!
    private var chosenColor:UIColor?
    
    var completion : ((team:Team, project:Project?) -> Void)?
    var showUser = false
}

// MARK: - View livecycle
extension TeamCreationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        projectNameTF.delegate = self
        teamNameTF.delegate = self
        userNameTF.delegate = self
        teamNameTF.becomeFirstResponder()
        if !showUser {
            teamNameTF.becomeFirstResponder()
            userNameTF.hidden = true
        }
        teamNameTF.padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        teamNameTF.setup(UIImage.Asset.Ic_team_mini.image, border: UIColor.draftLinkBlue(), innerColor: UIColor.draftLinkDarkBlue(), cornerRadius: 5)
        projectNameTF.padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        projectNameTF.setup(UIImage.Asset.Ic_project_mini.image, border: UIColor.draftLinkBlue(), innerColor: UIColor.draftLinkDarkBlue(), cornerRadius: 5)
        userNameTF.padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        userNameTF.setup(border: UIColor.draftLinkBlue(), innerColor: UIColor.draftLinkDarkBlue(), cornerRadius: 5)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: - Navigation
extension TeamCreationViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardSegue.CreationStoryboard.ColorSegue.rawValue {
            self.colorController = segue.destinationViewController as! ColorGenerationViewController
            self.colorController.delegate = self
            self.colorController.loadFromNil = true
        }
    }
}

// MARK: - TextField delegate
extension TeamCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.teamNameTF || textField == self.userNameTF {
            nextResponder()!.becomeFirstResponder()
        }
        else {
            view.endEditing(true)
        }
        return false
    }
}

extension TeamCreationViewController: ColorGenerationViewControllerDelegate {
    func didSelectColor(color: UIColor, seed: CGFloat) {
        chosenColor = color
    }
}

// MARK: - Actions
extension TeamCreationViewController {
    @IBAction func createTouch(sender: AnyObject) {
        
        guard let teamName = self.teamNameTF.text where teamName != "" else {
            //TODO: AlertView field team name empty
            return
        }
        guard let projectName = self.projectNameTF.text, chosenColor = chosenColor where projectName != "" else {
            //TODO: AlertView field project name empty
            return
        }
        if self.showUser {
            guard let userName = self.userNameTF.text where !self.userNameTF.hidden && userName != "" else {
                //TODO: AlertView field project name empty
                return
            }
            User.currentUser!.username = userName
        }
        
        Team.create(teamName, color: chosenColor, colorSeed: ColorGenerator.CGSharedInstance.currentSeed, completion: { (success, team) -> Void in
            Project.create(projectName, team: team, completion: { (project, team) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    User.currentUser!.addTeam(team, color: chosenColor, colorSeed: ColorGenerator.CGSharedInstance.currentSeed, completion: {
                        project.setLastOpenForTeam(team)
                        self.completion?(team: team, project:project)
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    })
                })
            })
        })
    }
    
}
