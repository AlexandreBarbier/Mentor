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

    var displayedDataSource : [User] = [] {
        didSet {
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    
    var team : Team! {
        didSet {
            self.segmentControl.setTitle(team.name, forSegmentAtIndex: 0)
            self.teamTableVC.show()
            self.team.getUsers { (users, error) -> Void in
                if error != nil {
                    
                    return
                }
                self.displayedDataSource = users
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let pan = UIPanGestureRecognizer(target: self, action: "pangesture:")
        self.view.addGestureRecognizer(pan)
    }
    
    override func viewDidLayoutSubviews() {
        self.openButton.backgroundColor = UIColor.lightGrayColor()
        self.openButton.roundedLeft(self.openButton.frame.width / 2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func pangesture(pan:UIPanGestureRecognizer) {
        let x = pan.translationInView(self.view).x

        switch pan.state {
        case .Began :
            previous = 0
            break
        case .Ended :
            if self.view.layer.frame.origin.x > self.view.frame.width / 2.0 {
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.view.layer.transform = CATransform3DIdentity
                    }, completion: { (finished) -> Void in
                })
            }
            else {
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.view.layer.transform = CATransform3DMakeTranslation(-(self.view.frame.size.width - 58), 0, 0)
                    }, completion: { (finished) -> Void in
                })
            }
            break
        case .Changed :
            if self.view.layer.frame.origin.x >= 0 && self.view.layer.frame.origin.x <= self.view.frame.size.width - 58 {
                self.view.layer.transform = CATransform3DConcat(self.view.layer.transform,CATransform3DMakeTranslation(x - previous, 0, 0))
                previous = x
            }
            break
        default :
            break
        }


    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayedDataSource.count
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("connectedUserCell", forIndexPath: indexPath)
        cell.textLabel!.text = self.displayedDataSource[indexPath.row].username
        return cell
    }

    @IBAction func show(sender: AnyObject) {
        if !shown {
            self.segmentControl.selectedSegmentIndex = 0
            self.segmentControlChanged(self.segmentControl)
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
        switch self.segmentControl.selectedSegmentIndex {
        case 0:
            self.teamContainer.hidden = true
            break
        case 1:
            self.teamContainer.hidden = false
            self.teamTableVC.show()
            break
        default :
            break
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "teamContainerVC" {
            let nav = segue.destinationViewController as! UINavigationController
            self.teamTableVC = nav.viewControllers.first as! TeamTableViewController
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
