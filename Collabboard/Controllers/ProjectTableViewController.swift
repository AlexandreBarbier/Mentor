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
            return Double((displayedDataSource.count * 50) == 0 ? 50 : (displayedDataSource.count * 50))
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

extension ProjectTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib.init(nibName: "ProjectTableViewCell", bundle: nil), forCellReuseIdentifier: "ProjectTableViewCell")
    }
}

extension ProjectTableViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardSegue.Main.ProjectCreationSegue.rawValue {
            let vc = segue.destinationViewController as! ProjectCreationViewController
            vc.team = self.team
            vc.completion = {(project:Project, team:Team) in
                self.displayedDataSource.append(project)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.displayedDataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                self.completion?(project: project,team: team)
            }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ProjectTableViewCell", forIndexPath: indexPath) as! ProjectTableViewCell
        
        cell.projectNameLabel.text = displayedDataSource[indexPath.row].name
        cell.infoLabel.text = displayedDataSource[indexPath.row].infos
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        displayedDataSource[indexPath.row].setLastOpenForTeam(team)
        completion?(project: displayedDataSource[indexPath.row], team: team)
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = AdditionFooterView.instanciate(withConfiguration: .Project, delegate: self)
        return v
    }
}