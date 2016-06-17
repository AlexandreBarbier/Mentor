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
    
    private var displayedDataSource = [Team]()  {
        didSet {
            title = "Team\(displayedDataSource.count > 1 ? "s" : "")"
        }
    }
    private var computedHeight : Double {
        get {
            return Double(displayedDataSource.count * 50)
        }
    }
    
    var completion:((project:Project, team:Team)->Void)?
}

// MARK: - view lifecycle
extension TeamTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "TeamTableViewCell", bundle: nil), forCellReuseIdentifier: "TeamTableViewCell")
    }
}

// MARK: - Helper
extension TeamTableViewController {
    func show () {
        guard let user = User.currentUser else {
            return
        }
        user.getTeams { (teams, local, error) -> Void in
            if let error = error {
                DebugConsoleView.debugView.errorPrint("get teams error \(error)")
            }
        
            self.displayedDataSource = teams
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.tableView.reloadData()
            })
        }
    }
}

// MARK: - Tableview delegate
extension TeamTableViewController : UITableViewDataSource, UITableViewDelegate  {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TeamTableViewCell") as! TeamTableViewCell
        let team = displayedDataSource[indexPath.row]
        if team.currentUserIsAdmin {
            cell.iconImageView.image = UIImage.Asset.Ic_team.image
        }
        else {
            cell.iconImageView.image = nil
        }
        cell.teamNameLabel.text = "\(team.name)"
        cell.tokenLabel.text = "token : \(displayedDataSource[indexPath.row].token)"
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegue(StoryboardSegue.Main.TeamCellSegue, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
   func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = AdditionFooterView.instanciate(withConfiguration: .Team, delegate: self)
        return v
    }
}

// MARK: - Navigation
extension TeamTableViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardSegue.Main.TeamCellSegue.rawValue {
            
            let index = self.tableView.indexPathForCell(sender as! TeamTableViewCell)
            let _ : ProjectTableViewController = {
                $0.completion = completion
                $0.displayedDataSource = [Project]()
                $0.team = displayedDataSource[index!.row]
                return $0
            } (segue.destinationViewController as! ProjectTableViewController)
        }
        
        if segue.identifier == StoryboardSegue.Main.TeamCreationSegue.rawValue {
            let teamCreationVC = segue.destinationViewController as! TeamCreationViewController
            teamCreationVC.completion = { (team, project) in
                self.displayedDataSource.append(team)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.displayedDataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
}

// MARK: - Actions
extension TeamTableViewController {
    @IBAction func joinTeamTouch(sender:AnyObject) {
        let alert = UIAlertController(title: "Team", message: "Join a team", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Team's token"
        })
        alert.addAction(UIAlertAction(title: "Join", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            guard let textField = alert.textFields!.first else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                })
                return
            }
            switch textField.text! {
            case "" :
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    alert.dismissViewControllerAnimated(false, completion: nil)
                })
                break
            default :
                Team.get(textField.text!, completion: { (team, error) -> Void in
                    guard let team1 = team else {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            alert.dismissViewControllerAnimated(false, completion: nil)
                        })
                        return
                    }
                    let colorAlert = StoryboardScene.Main.instantiateColorGeneratorVC()
                    colorAlert.team = team1
                    colorAlert.canChoose = true
                    colorAlert.completion = { (team:Team, color:UIColor, colorSeed:CGFloat) in
                        User.currentUser!.addTeam(team, color: color, colorSeed: colorSeed, completion: {
                            self.displayedDataSource.append(team)
                            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.displayedDataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                            colorAlert.dismissViewControllerAnimated(true, completion: nil)
                        })
                    }
                    self.addChildViewController(colorAlert)
                    colorAlert.view.alpha = 0.0
                    colorAlert.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200)
                    colorAlert.view.center = self.view.center
                    self.view.addSubview(colorAlert.view)
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        colorAlert.view.alpha = 1.0
                    })
                })
                break
            }
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
}