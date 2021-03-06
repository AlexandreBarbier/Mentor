//
//  ProjectCreationViewController.swift
//  Collabboard
//
//  Created by Alexandre barbier on 15/06/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class ProjectCreationViewController: UIViewController {
    @IBOutlet var projectnameTextField: DFTextField!
    @IBOutlet var createButton: UIButton!

    var team: Team!
    var completion:((_ project: Project, _ team: Team) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        projectnameTextField = {
            $0?.padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
            $0?.setup(Asset.icProjectMini.image,
                      border: UIColor.draftLinkBlue,
                      innerColor: UIColor.draftLinkDarkBlue,
                      cornerRadius: 5.0)
            return $0
        }(projectnameTextField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Actions
extension ProjectCreationViewController {

    @IBAction func onCreateTouch(_ sender: AnyObject) {
        if projectnameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
			Project.create(projectnameTextField.text!, team: self.team, completion: self.completion)
            navigationController!.popViewController(animated: true)
        }
    }
}
