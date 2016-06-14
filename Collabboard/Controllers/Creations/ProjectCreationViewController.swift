//
//  ProjectCreationViewController.swift
//  Collabboard
//
//  Created by Alexandre barbier on 15/06/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class ProjectCreationViewController: UIViewController {
    @IBOutlet var projectnameTextField: UITextField!
    @IBOutlet var createButton: UIButton!
    
    var team : Team!
    var completion:((project:Project, team:Team)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Actions
extension ProjectCreationViewController {
    
    @IBAction func onCreateTouch(sender: AnyObject) {
        Project.create(projectnameTextField.text!, team: self.team, completion: self.completion)
        self.navigationController!.popViewControllerAnimated(true)
    }
}