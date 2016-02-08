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

    @IBOutlet var tableView:UITableView!
    private var previous:CGFloat = 0.0
    var displayedDataSource : [User] = [] {
        didSet {
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    
    var team : Team! {
        didSet {
            self.team.getUsers { (users, error) -> Void in
                if error != nil {
                    print(error)
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
                    self.view.layer.transform = CATransform3DMakeTranslation(-(self.view.frame.size.width - 50), 0, 0)
                    }, completion: { (finished) -> Void in
                })
            }
            break
        case .Changed :
            if self.view.layer.frame.origin.x >= 0 && self.view.layer.frame.origin.x <= self.view.frame.size.width - 50 {
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
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.layer.transform = CATransform3DMakeTranslation(-(self.view.frame.size.width - 50), 0, 0)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
