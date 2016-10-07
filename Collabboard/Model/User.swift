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

class User : ABModelCloudKit {
	internal static var currentUser : User? = nil
	
	override class func recordType() -> String {
		return "Users"
	}
	
	var username:String = ""
	var teams : [CKReference] = [CKReference]()
	var teamColor: [CKReference] = [CKReference]()
	
	override func ignoreKey(_ key: String, value: AnyObject) -> Bool {
		if key == "teams" {
			for ref : CKReference in value as! [CKReference] {
				teams.append(ref)
			}
			return true
		}
		if key == "teamColor" {
			for ref : CKReference in value as! [CKReference] {
				teamColor.append(ref)
			}
			return true
		}
		return false
	}
	
	class func getCurrentUser(_ completion:@escaping (_ user:User?, _ error:NSError?)->()) {
		if let user = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.currentUser) as? Data {
			User.currentUser =  NSKeyedUnarchiver.unarchiveObject(with: user) as? User
			completion(User.currentUser, nil)
			User.currentUser!.refresh({ (updatedObj:User?) -> Void in
				guard let update = updatedObj else {
					return
				}
				User.currentUser = update
				let data = NSKeyedArchiver.archivedData(withRootObject: update)
				UserDefaults.standard.set(data, forKey: Constants.UserDefaultsKeys.currentUser)
				UserDefaults.standard.synchronize()
			})
		}
		else {
			CloudKitManager.container.fetchUserRecordID { (recordId, error) -> Void in
				guard let recId = recordId else {
					completion(nil, error as NSError?)
					return
				}
				CloudKitManager.publicDB.fetch(withRecordID: recId, completionHandler: { (record, error) -> Void in
					guard let rec = record else {
						completion(nil, error as NSError?)
						return
					}
					let usr = User(record: rec, recordId: recordId!)
					User.currentUser = usr
					User.currentUser!.localSave()
					completion(usr, nil)
				})
			}
		}
	}
	
	override func publicSave(_ completion: ((CKRecord?, NSError?) -> Void)?) {
		super.publicSave { (record, error) -> Void in
			guard let rec = record else {
				if let cp = completion {
					OperationQueue.main.addOperation({ () -> Void in
						cp(nil, error as NSError?)
					})
				}
				return
			}
			let usr = User(record: rec, recordId: rec.recordID)
			User.currentUser = usr
			User.currentUser!.localSave()
			if let cp = completion {
				OperationQueue.main.addOperation({ () -> Void in
					cp(rec, error as NSError?)
				})
			}
		}
	}
	
	fileprivate func localSave() {
		let data = NSKeyedArchiver.archivedData(withRootObject: self)
		UserDefaults.standard.set(data, forKey:Constants.UserDefaultsKeys.currentUser)
		UserDefaults.standard.synchronize()
	}
	
	func getTeams(_ completion:@escaping (_ teams:[Team], _ local:Bool, _ error:NSError?) -> Void) {
		if let teamsData = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.teamUserKey) as? Data {
			let teams = NSKeyedUnarchiver.unarchiveObject(with: teamsData) as? [Team]
			completion(teams!, true, nil)
		}
		super.getReferences(teams,completion: { (results:[Team], error) -> Void in
			let data = NSKeyedArchiver.archivedData(withRootObject: results)
			UserDefaults.standard.set(data, forKey:Constants.UserDefaultsKeys.teamUserKey)
			UserDefaults.standard.synchronize()
			completion(results, false, error)
		})
	}
	
	func getColors(_ completion:@escaping (_ teamColor:[UserTeamColor], _ error:NSError?) -> Void) {
		super.getReferences(teamColor, completion: { (results:[UserTeamColor], error) -> Void in
			completion(results, error)
		})
	}
	
	func getTeamColors(_ team:Team, completion:@escaping (_ teamColor:UIColor?, _ userTeamColor:UserTeamColor, _ error:NSError?) -> Void) {
		self.getColors { (teamColor, error) -> Void in
			teamColor.forEach({ (utColor) -> () in
				if utColor.teamName == team.recordId.recordName {
					completion(utColor.getColor(), utColor, nil)
				}
			})
		}
	}
	
	func updateColorForTeam(_ team: Team, color:UIColor, colorSeed:CGFloat, completion: @escaping () -> Void) {
		self.getTeamColors(team) { (teamColor, userTeamColor, error) in
			guard error == nil else {
				return
			}
			userTeamColor.color = NSKeyedArchiver.archivedData(withRootObject: color)
			userTeamColor.colorSeed = colorSeed
			userTeamColor.publicSave({ (record, error) in
				print(error)
				team.publicSave()
				completion()
			})
		}
	}
	
	func addTeam(_ team:Team, color:UIColor, colorSeed:CGFloat, completion:(()-> Void)? = nil) {
		
		team.users.append(CKReference(record: self.toRecord(), action: .none))
		self.teams.append(CKReference(record: team.toRecord(), action: .none))
		UserTeamColor.create(team, colorSeed: colorSeed, color: color, completion: {(utColor:UserTeamColor, error:NSError?) in
			if let error = error {
				print(error)
			}
			self.teamColor.append(CKReference(record: utColor.toRecord(), action: .none))
			self.saveBulk([utColor.toRecord(), team.toRecord()], completion:  completion)
			self.localSave()
		})
	}
}
