//
//  ConnectedUsersTableViewController.swift
//  Collabboard
//
//  Created by Alexandre barbier on 06/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

//TODO: add firebase + new connected indicator + improve animation


import UIKit

class ConnectedUsersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet var tableView:UITableView!
    @IBOutlet weak var teamContainer: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    private var previous:CGFloat = 0.0
    private var shown = false
    private var teamTableVC: TeamTableViewController!
    
    var teamCompletion:((project:Project, team:Team)->Void)? {
        didSet {
            teamTableVC.completion = teamCompletion
        }
    }
    var displayedDataSource : [User] = [] {
        didSet {
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    var team : Team! {
        didSet {
            segmentControl.setTitle(team.name, forSegmentAtIndex: 0)
            segmentControl.setTitle("Teams", forSegmentAtIndex: 1)
            teamTableVC.show()
            team.getUsers { (users, error) -> Void in
                if error != nil {
                    return
                }
                self.displayedDataSource = users
            }
        }
    }
}

// MARK: - View lifecycle
extension ConnectedUsersTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ConnectedUsersTableViewController.pangesture(_:)))
        view.addGestureRecognizer(pan)
    }
    
    override func viewDidLayoutSubviews() {
        openButton.backgroundColor = UIColor.lightGrayColor()
        openButton.roundedLeft(openButton.frame.width / 2)
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

// MARK: - Gestures
extension ConnectedUsersTableViewController {
    func pangesture(pan:UIPanGestureRecognizer) {
        let x = pan.translationInView(view).x
        
        switch pan.state {
        case .Began :
            previous = 0
            break
        case .Ended :
            if view.layer.frame.origin.x > view.frame.width / 2.0 {
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.view.layer.transform = CATransform3DIdentity
                    }, completion: nil)
            }
            else {
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.view.layer.transform = CATransform3DMakeTranslation(-(self.view.frame.size.width - 58), 0, 0)
                    }, completion: nil)
            }
            break
        case .Changed :
            if view.layer.frame.origin.x >= 0 && view.layer.frame.origin.x <= view.frame.size.width - 58 {
                view.layer.transform = CATransform3DConcat(view.layer.transform, CATransform3DMakeTranslation(x - previous, 0, 0))
                previous = x
            }
            break
        default :
            break
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
        let cell = tableView.dequeueReusableCellWithIdentifier("connectedUserCell", forIndexPath: indexPath)
        cell.textLabel!.text = displayedDataSource[indexPath.row].username
        return cell
    }
}

// MARK: - Actions
extension ConnectedUsersTableViewController {
    @IBAction func show(sender: AnyObject) {
        if !shown {
            segmentControl.selectedSegmentIndex = 0
            segmentControlChanged(self.segmentControl)
            UIView.animateWithDuration(0.5) { () -> Void in
                self.view.layer.transform = CATransform3DMakeTranslation(-(self.view.frame.size.width - 58), 0, 0)
            }
        }
        else {
            UIView.animateWithDuration(0.5) { () -> Void in
                self.view.layer.transform = CATransform3DIdentity
            }
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
