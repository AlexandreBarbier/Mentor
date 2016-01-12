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
    var completion : ((team:Team) -> Void)?
    
    
    @IBOutlet weak var projectNameTF: UITextField!
    @IBOutlet weak var teamNameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        projectNameTF.delegate = self
        teamNameTF.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.teamNameTF {
            self.projectNameTF.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return false
    }

    @IBAction func cancelTouch(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createTouch(sender: AnyObject) {
        guard let teamName = self.teamNameTF.text where teamName != "" else {
            //TODO: AlertView field team name empty
         return
        }
        guard let projectName = self.projectNameTF.text where projectName != ""else {
            //TODO: AlertView field project name empty
            return
        }
        Team.create(teamName,color: self.colorController.chosenColor, colorSeed: self.colorController.currentSeed, completion: { (success, team) -> Void in
            Project.create(projectName, team: team)
            self.dismissViewControllerAnimated(true, completion: nil)
            self.completion?(team: team)
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
