//
//  TeamTableViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 14/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit
import ABUIKit

class TeamTableViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var colorChooser: UIView!

    var createdTeam: Team?

    fileprivate var displayedDataSource = [Team]() {
        didSet {
            title = "Team\(displayedDataSource.count > 1 ? "s" : "")"
        }
    }

    fileprivate var computedHeight: Double {
        return Double(displayedDataSource.count * 50)
    }

    var completion:((_ project: Project, _ team: Team) -> Void)?
}

// MARK: - view lifecycle
extension TeamTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TeamTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "TeamTableViewCell")
    }
}

// MARK: - Helper
extension TeamTableViewController {
    func show () {
        guard let user = User.currentUser else {
            return
        }
        user.getTeams { (teams, _, error) -> Void in
            if let error = error {
                DebugConsoleView.debugView.errorPrint("get teams error \(error)")
            }

            self.displayedDataSource = teams
            OperationQueue.main.addOperation({ () -> Void in
                self.tableView.reloadData()
            })
        }
    }
}

// MARK: - Tableview delegate
extension TeamTableViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamTableViewCell") as? TeamTableViewCell
        let team = displayedDataSource[(indexPath as NSIndexPath).row]
        cell?.iconImageView.image = Asset.icTeam.image.withRenderingMode(.alwaysTemplate)
        cell?.iconImageView.tintColor = team.currentUserIsAdmin ? UIColor.draftLinkBlue : UIColor.draftLinkGrey
        cell?.teamNameLabel.text = "\(team.name)"
        cell?.tokenLabel.text = "token : \(displayedDataSource[(indexPath as NSIndexPath).row].token)"
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: StoryboardSegue.Main.teamCellSegue.rawValue,
                     sender: tableView.cellForRow(at: indexPath))
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = AdditionFooterView.instanciate(withConfiguration: .Team, delegate: self)
        return v
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .destructive, title: "Leave", handler: { (_, indexPath) in
            tableView.isEditing = true
            self.displayedDataSource[indexPath.row].remove()
            self.displayedDataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        })]
    }
}

// MARK: - Navigation
extension TeamTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.teamCellSegue.rawValue {
            if let controller = segue.destination as? ProjectTableViewController,
                let sender = sender as? TeamTableViewCell {
                let index = self.tableView.indexPath(for: sender)
                let _ : ProjectTableViewController = {
                    $0.completion = completion
                    $0.displayedDataSource = [Project]()
                    $0.team = displayedDataSource[(index! as NSIndexPath).row]
                    return $0
                } (controller)
            }
        }

        if segue.identifier == StoryboardSegue.Main.teamCreationSegue.rawValue {
            if let teamCreationVC = segue.destination as? TeamCreationViewController {
                teamCreationVC.completion = { (team, project) in
                    self.displayedDataSource.append(team)
                    self.tableView.insertRows(at: [IndexPath(row: self.displayedDataSource.count - 1, section: 0)],
                                              with: UITableViewRowAnimation.automatic)
                }
            }
        }
    }
}

extension TeamTableViewController : ColorGenerationViewControllerDelegate {
    func didSelectColor(_ color: UIColor, seed: CGFloat) {
        User.currentUser!.addTeam(createdTeam!, color: color, colorSeed: seed, completion: {
            self.displayedDataSource.append(self.createdTeam!)
            self.tableView.insertRows(at: [IndexPath(row: self.displayedDataSource.count - 1, section: 0)],
                                      with: UITableViewRowAnimation.automatic)
            //   colorAlert.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}

// MARK: - Actions
extension TeamTableViewController {
    @IBAction func joinTeamTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Team",
                                      message: "Join a team",
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Team's token"
        })
        alert.addAction(UIAlertAction(title: "Join", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            guard let textField = alert.textFields!.first else {
                OperationQueue.main.addOperation({ () -> Void in
                    alert.dismiss(animated: true, completion: nil)
                })
                return
            }
            switch textField.text! {
            case "" :
                OperationQueue.main.addOperation({ () -> Void in
                    alert.dismiss(animated: false, completion: nil)
                })
                break
            default :
                Team.get(textField.text!, completion: { (team, _) -> Void in
                    guard let team1 = team else {
                        OperationQueue.main.addOperation({ () -> Void in
                            alert.dismiss(animated: false, completion: nil)
                        })
                        return
                    }
                    let colorAlert = StoryboardScene.Main.instantiateColorGeneratorVC()
                    self.createdTeam = team1
                    self.addChildViewController(colorAlert)
                    colorAlert.view.alpha = 0.0
                    colorAlert.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200)
                    colorAlert.view.center = self.view.center
                    self.view.addSubview(colorAlert.view)
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        colorAlert.view.alpha = 1.0
                    })
                })
                break
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}
