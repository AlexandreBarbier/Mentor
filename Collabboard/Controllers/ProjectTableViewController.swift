//
//  ProjectTableViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 14/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit

class ProjectTableViewController: UITableViewController {
    
    private var computedHeight : Double {
        get {
            return Double((displayedDataSource.count * 50) == 0 ? 50: (displayedDataSource.count * 50))
        }
    }
    
    var completion:((project:Project, team:Team)->Void)?
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
    var displayedDataSource:[Project]! {
        didSet {
            title = "Project\(displayedDataSource.count > 1 ? "s": "")"
        }
    }
}

// MARK: - Table view data source
extension ProjectTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("projectCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = displayedDataSource[indexPath.row].name
        cell.detailTextLabel?.text = displayedDataSource[indexPath.row].infos
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        displayedDataSource[indexPath.row].setLastOpenForTeam(team)
        completion?(project: displayedDataSource[indexPath.row], team: team)
    }
}

// MARK: - Actions
extension ProjectTableViewController {
    @IBAction func createTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Project", message: "Create a new project", preferredStyle: UIAlertControllerStyle.Alert)
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}