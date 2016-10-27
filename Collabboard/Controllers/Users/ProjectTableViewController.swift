//
//  ProjectTableViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 14/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit

class ProjectTableViewController: UITableViewController {
    
    fileprivate var computedHeight : Double {
        get {
            return Double((displayedDataSource.count * 50) == 0 ? 50 : (displayedDataSource.count * 50))
        }
    }
    
    var completion:((_ project:Project, _ team:Team)->Void)?
    var team : Team! {
        didSet {
            team.getProjects { (projects, local, error) -> Void in
                OperationQueue.main.addOperation({ () -> Void in
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
        tableView.register(UINib.init(nibName: "ProjectTableViewCell", bundle: nil), forCellReuseIdentifier: "ProjectTableViewCell")
    }
}

extension ProjectTableViewController {
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == StoryboardSegue.Main.ProjectCreationSegue.rawValue {
            return team.admin == User.currentUser!.recordId.recordName
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.ProjectCreationSegue.rawValue {
            let vc = segue.destination as! ProjectCreationViewController
            vc.team = self.team
            vc.completion = { (project:Project, team:Team) in
                self.displayedDataSource.append(project)
                self.tableView.insertRows(at: [IndexPath(row: self.displayedDataSource.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
                self.completion?(project,team)
            }
        }
    }
}

// MARK: - Table view data source
extension ProjectTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTableViewCell", for: indexPath) as! ProjectTableViewCell
        
        cell.projectNameLabel.text = displayedDataSource[(indexPath as NSIndexPath).row].name
        cell.infoLabel.text = displayedDataSource[(indexPath as NSIndexPath).row].infos
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayedDataSource[(indexPath as NSIndexPath).row].setLastOpenForTeam(team)
        completion?(displayedDataSource[(indexPath as NSIndexPath).row], team)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return AdditionFooterView.instanciate(withConfiguration: .Project, delegate: self)
    }
}
