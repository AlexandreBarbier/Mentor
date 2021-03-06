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
    @IBOutlet var tableView: UITableView!
    @IBOutlet var teamContainer: UIView!
    @IBOutlet var segmentControl: UISegmentedControl!

    fileprivate var previous: CGFloat = 0.0
    fileprivate var shown = false
    fileprivate var teamTableVC: TeamTableViewController!

    var teamCompletion:((_ project: Project, _ team: Team) -> Void)?

    var displayedDataSource: [User] = [] {
        didSet {
            OperationQueue.main.addOperation { () -> Void in
                self.tableView.reloadData()
            }
        }
    }

    var team: Team? {
        didSet {
            team!.getUsers { (users, error) -> Void in
                if error != nil {
                    return
                }
                self.displayedDataSource = users
                if cbFirebase.users != nil {
                    cbFirebase.users.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                        guard let snapshotDictionary = snapshot.value as? [String: Bool] else {
                            return
                        }
                        for i in 0 ..< self.displayedDataSource.count {
                            if let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0))
                                as? UserTableViewCell {
                                let user = self.displayedDataSource[i]

                                if let connected = snapshotDictionary[user.recordId.recordName] {
                                    cell.presenceIndicatorView.backgroundColor = connected ? UIColor.green:UIColor.red
                                } else {
                                    cell.presenceIndicatorView.backgroundColor = UIColor.draftLinkGrey
                                }
                            }
                        }
                    })
                    cbFirebase.firebaseUserObserverHandle = cbFirebase.users.observe(FIRDataEventType.childChanged) {
                        (snap: FIRDataSnapshot) -> Void in

                        OperationQueue.main.addOperation({
                            let index = self.displayedDataSource.index(where: { (user) -> Bool in
                                return user.recordId.recordName == snap.key
                            })
                            if index != nil {
                                if let cell = self.tableView.cellForRow(at: IndexPath(row: index!, section: 0))
                                    as? UserTableViewCell {
                                    if let connected = snap.value as? Bool {
                                        cell.presenceIndicatorView.backgroundColor = connected ?
                                            UIColor.green :
                                            UIColor.red
                                    }
                                }
                            }
                        })
                    }
                    cbFirebase.users.updateChildValues([User.currentUser!.recordId.recordName: true])
                }
            }
        }
    }

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as? UserTableViewCell
		let user = displayedDataSource[(indexPath as NSIndexPath).row]
		cell?.usernameLabel.text = user.username
		user.getTeamColors(team!) { (teamColor, _, _) in
			cell?.avatarView.backgroundColor = teamColor
		}
		return cell!
	}
}

// MARK: - View lifecycle
extension ConnectedUsersTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: UserTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: UserTableViewCell.identifier)
        segmentControl = {
            $0?.tintColor = UIColor.draftLinkBlue
            $0?.backgroundColor = UIColor.draftLinkGrey
            return $0
        }(segmentControl)
        segmentControl.selectedSegmentIndex = 1
        backSegmentationView.backgroundColor = UIColor.draftLinkGrey
        view.backgroundColor = UIColor.clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
    }

    func reload() {
        if let segmentControl = segmentControl {
            segmentControl.setTitle("Live", forSegmentAt: 0)
            segmentControl.setTitle("Project management", forSegmentAt: 1)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.teamContainerVC.rawValue {
            let nav = segue.destination as? UINavigationController
            teamTableVC = nav?.viewControllers.first as? TeamTableViewController
        }
    }
}

// MARK: - TableView delegate
extension ConnectedUsersTableViewController {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDataSource.count
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return AdditionFooterView.instanciate(withConfiguration: .Users, delegate: self)
    }
}

// MARK: - Actions
extension ConnectedUsersTableViewController {
    @IBAction func show(_ sender: AnyObject) {
        var transform = CATransform3DIdentity
        if !shown {
            segmentControl.selectedSegmentIndex = 0
            segmentControlChanged(self.segmentControl)
            transform = CATransform3DMakeTranslation(0, -self.view.frame.size.height, 0)
        }

        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layer.transform = transform
        })
        shown = !shown
    }

    @IBAction func segmentControlChanged(_ sender: AnyObject) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            teamContainer.isHidden = true
            break
        case 1:
            teamContainer.isHidden = false
            teamTableVC.show()
            break
        default :
            break
        }
    }
}
