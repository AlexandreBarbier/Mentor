//
//  TeamCreationViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 12/01/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class TeamCreationViewController: UIViewController {
    
    @IBOutlet weak var projectNameTF: UITextField!
    @IBOutlet weak var teamNameTF: UITextField!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    private var colorController : ColorGenerationViewController!
    
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
            userNameLabel.hidden = true
        }
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

// MARK: - Actions
extension TeamCreationViewController {
    @IBAction func createTouch(sender: AnyObject) {
        
        guard let teamName = self.teamNameTF.text where teamName != "" else {
            //TODO: AlertView field team name empty
            return
        }
        guard let projectName = self.projectNameTF.text where projectName != "" else {
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
        self.activity.startAnimating()
        Team.create(teamName,color: self.colorController.chosenColor, colorSeed: ColorGenerator.CGSharedInstance.currentSeed, completion: { (success, team) -> Void in
            Project.create(projectName, team: team, completion: { (project, team) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    User.currentUser!.addTeam(team, color: self.colorController.chosenColor, colorSeed: ColorGenerator.CGSharedInstance.currentSeed, completion: {
                        self.activity.stopAnimating()
                        project.setLastOpenForTeam(team)
                        self.completion?(team: team, project:project)
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    })
                })
            })
        })
    }

}
