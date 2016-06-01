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
    
    var name:String = ""
    var users : [CKReference] = [CKReference]()
    var projects : [CKReference] = [CKReference]()
    var token : String = ""
    var infos = ""
    var admin:String = ""
    
    override class func recordType() -> String {
        return "Teams"
    }
    
    var currentUserIsAdmin:Bool {
        get {
            if let currentUser = User.currentUser {
                return currentUser.recordId.recordName == self.admin
            }
            return false
        }
    }
}

// MARK: - ABModel
extension Team {
    
    
    
    override func ignoreKey(key: String, value: AnyObject) -> Bool {
        if key == "users" {
            for ref : CKReference in value as! [CKReference] {
                users.append(ref)
            }
            return true
        }
        if key == "projects" {
            for ref : CKReference in value as! [CKReference] {
                projects.append(ref)
            }
            return true
        }
        return false
    }
}

// MARK: - Creation
extension Team {
    class func create(name:String, color:UIColor, colorSeed:CGFloat, completion:(success:Bool, team:Team) -> Void) -> Team {
        
        let team: Team = {
            $0.name = name
            $0.token = "\(name)\(arc4random_uniform(UInt32(100)))"
            if let currentUser = User.currentUser {
                $0.admin = currentUser.recordId.recordName
                currentUser.addTeam($0, color: color, colorSeed: colorSeed)
                completion(success: true, team: $0)
            }
            return $0
        }(Team())
        return team
    }
}

// MARK: - fetches
extension Team {
    
    class func get(token:String, completion:(team:Team?, error:NSError?) -> Void) {
        Team.getRecord("token=\'\(token)\'") { (record, error)  in
            guard let record = record else {
                completion(team: nil, error: error)
                return
            }
            let team = Team(record: record, recordId: record.recordID)
            completion(team: team, error: nil)
        }
    }
    
    func getProjects(completion:(projects:[Project], local:Bool, error:NSError?) -> Void) {
        if let projectsData = NSUserDefaults.standardUserDefaults().objectForKey("\(Constants.UserDefaultsKeys.teamProjects)\(self.name)") as? NSData {
            let projects = NSKeyedUnarchiver.unarchiveObjectWithData(projectsData) as? [Project]
            completion(projects: projects!, local:true, error: nil)
        }
        super.getReferences(projects,completion: { (results:[Project], error) -> Void in
            let data = NSKeyedArchiver.archivedDataWithRootObject(results)
            NSUserDefaults.standardUserDefaults().setObject(data, forKey:"\(Constants.UserDefaultsKeys.teamProjects)\(self.name)")
            NSUserDefaults.standardUserDefaults().synchronize()
            completion(projects: results, local:false, error: error)
        })
    }
    
    func getUsers(completion:(users:[User], error:NSError?) -> Void) {
        super.getReferences(users, completion: { (results:[User], error) -> Void in
            completion(users: results, error: error)
        })
    }
}
