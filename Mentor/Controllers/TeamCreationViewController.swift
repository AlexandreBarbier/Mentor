//
//  TeamCreationViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 12/01/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class TeamCreationViewController: UIViewController, UITextFieldDelegate {
    
    private var colorController : ColorGenerationViewController!
    var completion : ((team:Team, project:Project?) -> Void)?
    
    var showUser = false
    @IBOutlet weak var projectNameTF: UITextField!
    @IBOutlet weak var teamNameTF: UITextField!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.teamNameTF || textField == self.userNameTF {
            self.nextResponder()!.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return false
    }
    
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
            KCurrentUser!.username = userName
        }
        self.activity.startAnimating()
        Team.create(teamName,color: self.colorController.chosenColor, colorSeed: self.colorController.currentSeed, completion: { (success, team) -> Void in
            Project.create(projectName, team: team, completion: { (project, team) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    KCurrentUser!.addTeam(team, color: self.colorController.chosenColor, colorSeed: self.colorController.currentSeed, completion: {
                        self.activity.stopAnimating()
                        self.completion?(team: team, project:project)
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    })
                    
                })
                
            })
            
            
            
        })
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ColorSegue" {
            self.colorController = segue.destinationViewController as! ColorGenerationViewController
        }
    }
}
