//
//  Team.swift
//  Mentor
//
//  Created by Alexandre barbier on 07/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit
import ABModel
import CloudKit
import Foundation

class Team: ABModelCloudKit {

    var name: String = ""
    var users: [CKReference] = [CKReference]()
    var projects: [CKReference] = [CKReference]()
    var token: String = ""
    var infos = ""
    var admin: String = ""

    override class func recordType() -> String {
        return "Teams"
    }

    var currentUserIsAdmin: Bool {
        if let currentUser = User.currentUser {
            return currentUser.recordId.recordName == self.admin
        }
        return false
    }
}

// MARK: - ABModel
extension Team {

    override func ignoreKey(_ key: String, value: AnyObject) -> Bool {
        if key == "users" {
            for ref: CKReference in (value as? [CKReference])! {
                users.append(ref)
            }
            return true
        }
        if key == "projects" {
            for ref: CKReference in (value as? [CKReference])! {
                projects.append(ref)
            }
            return true
        }
        return false
    }
}

// MARK: - Creation
extension Team {
	@discardableResult class func create(_ name: String,
	                                     color: UIColor,
	                                     colorSeed: CGFloat,
	                                     completion: (_ success: Bool, _ team: Team) -> Void) -> Team {

        let team: Team = {
            $0.name = name
            $0.token = "\(name)\(arc4random_uniform(UInt32(100)))"
            if let currentUser = User.currentUser {
                $0.admin = currentUser.recordId.recordName
                completion(true, $0)
            }
            return $0
        }(Team())
        return team
    }
}

// MARK: - fetches
extension Team {

    class func get(_ token: String, completion: ((_ team: Team?, _ error: NSError?) -> Void)? = nil) {
        Team.getRecord("token=\'\(token)\'") { (record, error)  in
            guard let record = record else {
                completion?(nil, error)
                return
            }
            let team = Team(record: record, recordId: record.recordID)
            completion?(team, nil)
        }
    }

    func getProjects(_ completion:((_ projects: [Project], _ local: Bool, _ error: NSError?) -> Void)? = nil) {
        let key = "\(Constants.UserDefaultsKeys.teamProjects)\(self.name)"
        if let projectsData = UserDefaults.standard.object(forKey: key) as? Data {
            let projects = NSKeyedUnarchiver.unarchiveObject(with: projectsData) as? [Project]
            completion?(projects!, true, nil)
        }

        getReferences(projects, completion: { (results: [Project], error) -> Void in
            let data = NSKeyedArchiver.archivedData(withRootObject: results)
            UserDefaults.standard.set(data, forKey: "\(Constants.UserDefaultsKeys.teamProjects)\(self.name)")
            UserDefaults.standard.synchronize()
            completion?(results, false, error)
        })
    }

    func getUsers(_ completion: ((_ users: [User], _ error: NSError?) -> Void)? = nil) {
        getReferences(users, completion: { (results: [User], error) -> Void in
            completion?(results, error)
        })
    }

    override func remove() {
        if let teamsData = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.teamUserKey) as? Data {
            var teams = NSKeyedUnarchiver.unarchiveObject(with: teamsData) as? [Team]
            teams!.remove(at: teams!.index(where: { (team) -> Bool in
                return team.name == self.name
            })!)
        }
        User.currentUser?.removeTeam(recordID: self.recordId)
    }
}
