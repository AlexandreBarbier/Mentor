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
    
    var currentUserIsAdmin:Bool {
        get {
            if let currentUser = KCurrentUser {
                return currentUser.recordId.recordName == self.admin
            }
            return false
        }
    }
    
    override class func recordType() -> String {
        return "Teams"
    }
    
    override func ignoreKey(key: String, value: AnyObject) -> Bool {
        if key == "users" {
            self.users = [CKReference]()
            for ref : CKReference in value as! [CKReference] {
                self.users.append(ref)
            }
            return true
        }
        if key == "projects" {
            self.projects = [CKReference]()
            for ref : CKReference in value as! [CKReference] {
                self.projects.append(ref)
            }
            
            return true
        }
        return false
    }
}

// MARK: - Creation
extension Team {
    class func create(name:String, color:UIColor, completion:(success:Bool, team:Team) -> Void) -> Team {
        let team = Team()
        team.name = name
        team.token = "\(name)\(arc4random() % 100)"
        if let currentUser = KCurrentUser {
            team.users = [CKReference(record: currentUser.record!, action: .None)]
            team.admin = currentUser.recordId.recordName
            currentUser.addTeam(team, color: color)
            completion(success: true, team: team)
        }
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
    
    func getProjects(completion:(projects:[Project], error:NSError?) -> Void) {
        super.getReferences(projects, completion: { (results:[Project], error) -> Void in
            completion(projects: results, error: error)
        })
        
    }
    
    func getUsers(completion:(users:[User], error:NSError?) -> Void) {
        super.getReferences(users,completion: { (results:[User], error) -> Void in
            completion(users: results, error: error)
        })
    }
}
