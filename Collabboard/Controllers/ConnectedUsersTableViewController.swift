//
//  ConnectedUsersTableViewController.swift
//  Collabboard
//
//  Created by Alexandre barbier on 06/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

//TODO: add firebase + new connected indicator + improve animation


import UIKit
import FirebaseDatabase

class ConnectedUsersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var backSegmentationView: UIView!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var teamContainer: UIView!
    @IBOutlet var segmentControl: UISegmentedControl!
    
    private var previous: CGFloat = 0.0
    private var shown = false
    private var teamTableVC: TeamTableViewController!
    
    var teamCompletion:((project:Project, team:Team)->Void)?
    
    var displayedDataSource : [User] = [] {
        didSet {
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    
    var team : Team? {
        didSet {
            team!.getUsers { (users, error) -> Void in
                if error != nil {
                    return
                }
                if let cbUsers = cbFirebase.users {
                    cbUsers.updateChildValues([User.currentUser!.recordId.recordName:false])
                }
                self.displayedDataSource = users
                cbFirebase.users.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                    print("Full snap \(snapshot)")
                })
                cbFirebase.firebaseUserObserverHandle = cbFirebase.users.observeEventType(FIRDataEventType.ChildChanged) { (snap: FIRDataSnapshot) -> Void in
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        let index = self.displayedDataSource.indexOf({ (user) -> Bool in
                            if user.recordId.recordName == snap.key {
                                return true
                            }
                            return false
                        })
                        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index!, inSection: 0)) as! UserTableViewCell
                        
                        if snap.key != User.currentUser!.recordId.recordName {
                            let connected = snap.value as! Bool
                            cell.presenceIndicatorView.backgroundColor = connected ? UIColor.greenColor():UIColor.redColor()
                        }
                        else {
                            cell.presenceIndicatorView.backgroundColor = UIColor.greenColor()
                        }
                    })
                }
                cbFirebase.users.updateChildValues([User.currentUser!.recordId.recordName:true])
            }
        }
    }
}

// MARK: - View lifecycle
extension ConnectedUsersTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
        segmentControl = {
            $0.tintColor = UIColor.draftLinkBlueColor()
            $0.backgroundColor = UIColor.draftLinkGreyColor()
            return $0
        }(segmentControl)
        
        backSegmentationView.backgroundColor = UIColor.draftLinkGreyColor()
        view.backgroundColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reload()
        segmentControl.selectedSegmentIndex = 1
    }
    
    func reload() {
        if let team = team, segmentControl = segmentControl {
            segmentControl.setTitle(team.name, forSegmentAtIndex: 0)
            segmentControl.setTitle("Teams", forSegmentAtIndex: 1)
            teamTableVC.show()
            teamTableVC.completion = teamCompletion
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Navigation
extension ConnectedUsersTableViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardSegue.Main.TeamContainerVC.rawValue {
            let nav = segue.destinationViewController as! UINavigationController
            teamTableVC = nav.viewControllers.first as! TeamTableViewController
        }
    }
}

// MARK: - TableView delegate
extension ConnectedUsersTableViewController {
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCell", forIndexPath: indexPath) as! UserTableViewCell
        let user = displayedDataSource[indexPath.row]
        cell.usernameLabel.text = user.username
        user.getTeamColors(team!) { (teamColor, userTeamColor, error) in
            cell.avatarView.backgroundColor = teamColor
        }
        return cell
    }
}

// MARK: - Actions
extension ConnectedUsersTableViewController {
    @IBAction func show(sender: AnyObject) {
        var transform = CATransform3DIdentity
        if !shown {
            segmentControl.selectedSegmentIndex = 0
            segmentControlChanged(self.segmentControl)
            transform = CATransform3DMakeTranslation(0, -self.view.frame.size.height, 0)
        }
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.layer.transform = transform
        }
        
        shown = !shown
    }
    
    @IBAction func segmentControlChanged(sender: AnyObject) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            teamContainer.hidden = true
            break
        case 1:
            teamContainer.hidden = false
            teamTableVC.show()
            break
        default :
            break
        }
    }
}
