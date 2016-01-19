//
//  ProjectTableViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 14/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit

class ProjectTableViewController: UITableViewController {
    
    var team : Team! {
        didSet {
            team.getProjects { (projects, local, error) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.displayedDataSource = projects
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    var completion:((project:Project, team:Team)->Void)?
    
    var displayedDataSource:[Project]! {
        didSet {
            self.title = "Project\(self.displayedDataSource.count > 1 ? "s": "")"
        }
    }
    
    private var computedHeight : Double {
        get {
            return Double((self.displayedDataSource.count * 50) == 0 ? 50: (self.displayedDataSource.count * 50))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDataSource.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("projectCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.displayedDataSource[indexPath.row].name
        cell.detailTextLabel?.text = self.displayedDataSource[indexPath.row].infos
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.completion?(project: self.displayedDataSource[indexPath.row], team: self.team)
    }
    
    @IBAction func createTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Project", message: "create a new project", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "project name"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .Default, handler: { (action) -> Void in
            if let textF = alert.textFields!.first where textF.text != "" {
                let project = Project.create(textF.text!, team: self.team, completion: self.completion)
                self.displayedDataSource.append(project)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.displayedDataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            
        }))
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    
}
