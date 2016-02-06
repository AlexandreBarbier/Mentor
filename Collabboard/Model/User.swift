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

class User : ABModelCloudKit {
    internal static var currentUser : User? = nil
    
    override class func recordType() -> String {
        return "Users"
    }
    
    var username:String = ""
    var teams : [CKReference] = [CKReference]()
    var teamColor: [CKReference] = [CKReference]()
    
    override func ignoreKey(key: String, value: AnyObject) -> Bool {
        if key == "teams" {
            for ref : CKReference in value as! [CKReference] {
                self.teams.append(ref)
            }
            return true
        }
        if key == "teamColor" {
            for ref : CKReference in value as! [CKReference] {
                self.teamColor.append(ref)
            }
            return true
        }
        return false
    }
    
    class func getCurrentUser(completion:(user:User?, error:NSError?)->()) {
        if let user = NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserDefaultsKeys.currentUser) as? NSData {
            User.currentUser =  NSKeyedUnarchiver.unarchiveObjectWithData(user) as? User
            completion(user: User.currentUser, error: nil)
            User.currentUser!.refresh({ (updatedObj:User?) -> Void in
                if let update = updatedObj {
                    User.currentUser = update
                    let data = NSKeyedArchiver.archivedDataWithRootObject(update)
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: Constants.UserDefaultsKeys.currentUser)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            })
        }
        else {
            CloudKitManager.container.fetchUserRecordIDWithCompletionHandler { (recordId, error) -> Void in
                guard let recId = recordId else {
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
                    User.currentUser!.localSave()
                    completion(user: usr, error: nil)
                })
            }
        }
    }
    
    override func publicSave(completion: ((record: CKRecord?, error: NSError?) -> Void)? = nil) {
        super.publicSave { (record, error) -> Void in
            guard let rec = record else {
                if let cp = completion {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        cp(record: nil, error: error)
                    })
                }
                return
            }
            let usr = User(record: rec, recordId: rec.recordID)
            User.currentUser = usr
            User.currentUser!.localSave()
            if let cp = completion {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    cp(record: rec, error: error)
                })
                
            }
        }
    }
    
    private func localSave() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey:Constants.UserDefaultsKeys.currentUser)
                NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getTeams(completion:(teams:[Team], local:Bool, error:NSError?) -> Void) {
        if let teamsData = NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserDefaultsKeys.teamUserKey) as? NSData {
            let teams = NSKeyedUnarchiver.unarchiveObjectWithData(teamsData) as? [Team]
            completion(teams: teams!, local: true, error: nil)
        }
        super.getReferences(teams,completion: { (results:[Team], error) -> Void in
            let data = NSKeyedArchiver.archivedDataWithRootObject(results)
            NSUserDefaults.standardUserDefaults().setObject(data, forKey:Constants.UserDefaultsKeys.teamUserKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            completion(teams: results, local: false, error: error)
        })
    }
    
    func getColors(completion:(teamColor:[UserTeamColor], error:NSError?) -> Void) {
        super.getReferences(teamColor,completion: { (results:[UserTeamColor], error) -> Void in
            completion(teamColor: results, error: error)
        })
    }
    
    func getTeamColor(team:Team, completion:(teamColor:UIColor,userTeamColor:UserTeamColor, error:NSError?) -> Void) {
        self.getColors { (teamColor, error) -> Void in
            teamColor.forEach({ (utColor) -> () in
                if utColor.teamName == team.recordId.recordName {
                    completion(teamColor: utColor.getColor(), userTeamColor: utColor, error: nil)
                }
            })
        }
    }
    
    func addTeam(team:Team, color:UIColor, colorSeed:CGFloat, completion:(()-> Void)? = nil) {
        UserTeamColor.create(team, colorSeed: colorSeed, color: color, completion: {(utColor:UserTeamColor, error:NSError?) in
            self.teamColor.append(CKReference(record: utColor.toRecord(), action: .None))
            team.users.append(CKReference(record: self.toRecord(), action: .None))
            self.teams.append(CKReference(record: team.toRecord(), action: .None))
            self.saveBulk([utColor.toRecord(), team.toRecord()], completion:  completion)
            self.localSave()
            
        })
    }
}
