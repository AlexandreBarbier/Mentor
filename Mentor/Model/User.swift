//
//  User.swift
//  Mentor
//
//  Created by Alexandre barbier on 07/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit
import ABModel
import CloudKit

let KCurrentUser = User.currentUser

struct UserDefaultsKeys {
    static let currentUser = "currentUser"
}

class User : ABModelCloudKit {
    internal static var currentUser : User? = nil
    
    override class func recordType() -> String {
        return "Users"
    }
    
    var username:String = ""
    var teams : [CKReference] = []
    var teamColor: [CKReference] = []
    
    override func ignoreKey(key: String, value: AnyObject) -> Bool {
        if key == "teams" {
            self.teams = value as! [CKReference]
            return true
        }
        if key == "teamColor" {
            self.teamColor = value as! [CKReference]
            return true
        }
        return false
    }
    
    class func getCurrentUser(completion:(user:User?, error:NSError?)->()) {
        if let user = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultsKeys.currentUser) as? NSData {
            User.currentUser =  NSKeyedUnarchiver.unarchiveObjectWithData(user) as? User
            completion(user: User.currentUser, error: nil)
            User.currentUser!.refresh({ (updatedObj:User?) -> Void in
                if let update = updatedObj {
                    User.currentUser = update
                    let data = NSKeyedArchiver.archivedDataWithRootObject(update)
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: UserDefaultsKeys.currentUser)
                }
            })
        }
        else {
            CloudKitManager.container.fetchUserRecordIDWithCompletionHandler { (recordId, error) -> Void in
                guard let recId = recordId else {
                    debugPrint("get current user error \(error)")
                    completion(user: nil, error: error)
                    return
                }
                CloudKitManager.publicDB.fetchRecordWithID(recId, completionHandler: { (record, error) -> Void in
                    guard let rec = record else {
                        completion(user: nil, error: error)
                        return
                    }
                    let usr = User(record: rec, recordId: recordId!)
                    
                    User.currentUser = usr
                    let data = NSKeyedArchiver.archivedDataWithRootObject(usr)
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey:UserDefaultsKeys.currentUser)
                    completion(user: usr, error: nil)
                })
            }
        }
    }
    
    override func publicSave(completion: ((record: CKRecord?, error: NSError?) -> Void)? = nil) {
        super.publicSave { (record, error) -> Void in
            guard let rec = record else {
                print("User public save error : \(error)")
                if let cp = completion {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        cp(record: nil, error: error)
                    })
                }
                return
            }
            let usr = User(record: rec, recordId: rec.recordID)
            User.currentUser = usr
            let data = NSKeyedArchiver.archivedDataWithRootObject(usr)
            NSUserDefaults.standardUserDefaults().setObject(data, forKey:UserDefaultsKeys.currentUser)
            if let cp = completion {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    cp(record: rec, error: error)
                })
                
            }
        }
    }
    
    func getTeams(completion:(teams:[Team], error:NSError?) -> Void) {
        super.getReferences(teams,completion: { (results:[Team], error) -> Void in
            completion(teams: results, error: error)
        })
    }
    
    func getColors(completion:(teamColor:[UserTeamColor], error:NSError?) -> Void) {
        super.getReferences(teamColor,completion: { (results:[UserTeamColor], error) -> Void in
            completion(teamColor: results, error: error)
        })
    }
    
    func getTeamColor(team:Team, completion:(teamColor:UIColor, error:NSError?) -> Void) {
        self.getColors { (teamColor, error) -> Void in
            teamColor.forEach({ (utColor) -> () in
                if utColor.teamName == team.recordId.recordName {
                    completion(teamColor: utColor.getColor(), error: nil)
                }
            })
        }
    }
    
    func addTeam(team:Team, color:UIColor) {
        UserTeamColor.create(team, color: color, completion: {(utColor:UserTeamColor, error:NSError?) in
            self.teamColor.append(CKReference(record: utColor.toRecord(), action: .None))
            self.teams.append(CKReference(record: team.toRecord(), action: .None))
            self.saveBulk([utColor.toRecord(), team.toRecord()], completion:  nil)
        })
    }
}
