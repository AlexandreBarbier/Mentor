//
//  TeamTableViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 14/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit
import ABUIKit

let popoverWidth:Double = UIScreen.mainScreen().bounds.width <= 375.0 ? Double(UIScreen.mainScreen().bounds.width - 16.0) : 375.0 - 16.0

class TeamTableViewController: MPopoverViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var displayedDataSource:[Team]! {
        didSet {
            self.title = "Team\(self.displayedDataSource.count > 1 ? "s": "")"
            self.preferredContentSize = CGSize(width: popoverWidth, height: computedHeight)
        }
    }
    
    private var completion:((project:Project, team:Team)->Void)?
    
    private var computedHeight : Double {
        get {
            return Double(self.displayedDataSource.count * 50)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Team", message: "create a new team", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "team name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .Default, handler: { (action) -> Void in
            if let textF = alert.textFields!.first {
                
                let colorAlert = UIAlertController(title: "Choose a color", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                colorAlert.addAction(UIAlertAction(title: "blue", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    Team.create(textF.text!,color: UIColor.blueColor(), completion: { (success, team) -> Void in
                        self.displayedDataSource.append(team)
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.displayedDataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.preferredContentSize = CGSize(width: popoverWidth, height:self.computedHeight)
                    })
                }))
                colorAlert.addAction(UIAlertAction(title: "green", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    Team.create(textF.text!,color: UIColor.greenColor(), completion: { (success, team) -> Void in
                        self.displayedDataSource.append(team)
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.displayedDataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.preferredContentSize = CGSize(width: popoverWidth, height:self.computedHeight)
                    })
                }))
                colorAlert.addAction(UIAlertAction(title: "red", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    Team.create(textF.text!,color: UIColor.redColor(), completion: { (success, team) -> Void in
                        self.displayedDataSource.append(team)
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.displayedDataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.preferredContentSize = CGSize(width: popoverWidth, height:self.computedHeight)
                    })
                }))
                self.presentViewController(colorAlert, animated: true, completion: nil)
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func present(viewController:UIViewController, sourceFrame:CGRect, inNavigationController:UINavigationController? = nil, completion:((project:Project, team:Team)->Void)? = nil) {
        DebugConsoleView.debugView.print("present popover")
        guard let user = KCurrentUser else {
            DebugConsoleView.debugView.errorPrint("Team popover no user")
            return
        }
        self.completion = completion
        user.getTeams { (teams, error) -> Void in
            if let error = error {
                DebugConsoleView.debugView.errorPrint("get teams error \(error)")
            }
            self.displayedDataSource = teams
            super.present(viewController, sourceFrame: sourceFrame, inNavigationController: inNavigationController)
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayedDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("teamCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "teamCell")
        }
        let team = self.displayedDataSource![indexPath.row]
        if team.currentUserIsAdmin {
            cell!.imageView?.image = UIImage(named: "ProfileBlackIcon")
        }
        else {
            cell!.imageView?.image = nil
        }
        cell!.textLabel!.text = "\(team.name)"
        cell!.detailTextLabel!.text = "token : \(self.displayedDataSource![indexPath.row].token)"
        cell!.textLabel?.numberOfLines = 0

        return cell!
    }
    
    @IBAction func joinTeamTouch(sender: AnyObject) {
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
                    guard let team = team else {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            alert.dismissViewControllerAnimated(false, completion: nil)
                        })
                        return
                    }
                    //TODO: Choose color
                    let colorAlert = UIAlertController(title: "Choose a color", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    colorAlert.addAction(UIAlertAction(title: "blue", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        KCurrentUser!.addTeam(team, color:UIColor.blackColor())
                        KCurrentUser!.publicSave()
                        
                        self.displayedDataSource.append(team)
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.displayedDataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.preferredContentSize = CGSize(width: popoverWidth, height:self.computedHeight)
                    }))
                    colorAlert.addAction(UIAlertAction(title: "green", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        KCurrentUser!.addTeam(team, color:UIColor.blackColor())
                        KCurrentUser!.publicSave()
                        
                        self.displayedDataSource.append(team)
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.displayedDataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.preferredContentSize = CGSize(width: popoverWidth, height:self.computedHeight)
                    }))
                    colorAlert.addAction(UIAlertAction(title: "red", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        KCurrentUser!.addTeam(team, color:UIColor.blackColor())
                        KCurrentUser!.publicSave()
                        
                        self.displayedDataSource.append(team)
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.displayedDataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.preferredContentSize = CGSize(width: popoverWidth, height:self.computedHeight)
                    }))
                    self.presentViewController(colorAlert, animated: true, completion: nil)
                })
                
                break
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let projectVC = segue.destinationViewController as? ProjectTableViewController
        let index = self.tableView.indexPathForCell(sender as! UITableViewCell)
        projectVC!.completion = completion
        projectVC!.displayedDataSource = [Project]()
        projectVC!.team =  self.displayedDataSource[index!.row]
    }
    
    
}
