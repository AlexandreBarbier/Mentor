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

class User: ABModelCloudKit {
	internal static var currentUser: User? = nil

	override class func recordType() -> String {
		return "Users"
	}

	var username: String = ""
	var teams: [CKReference] = [CKReference]()
	var teamColor: [CKReference] = [CKReference]()

	override func ignoreKey(_ key: String, value: AnyObject) -> Bool {
		if key == "teams", let refs = value as? [CKReference] {
			for ref: CKReference in refs {
				teams.append(ref)
			}
			return true
		}
		if key == "teamColor", let refs = value as?[CKReference] {
			for ref: CKReference in refs {
				teamColor.append(ref)
			}
			return true
		}
		return false
	}

	class func getCurrentUser(_ completion:((_ user: User?, _ error: NSError?) -> Void)? = nil) {
		if let user = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.currentUser) as? Data {
			User.currentUser = NSKeyedUnarchiver.unarchiveObject(with: user) as? User
			completion?(User.currentUser, nil)
			User.currentUser!.refresh({ (updatedObj: User?) -> Void in
				guard let update = updatedObj else {
					return
				}
				User.currentUser = update
				let data = NSKeyedArchiver.archivedData(withRootObject: update)
				UserDefaults.standard.set(data, forKey: Constants.UserDefaultsKeys.currentUser)
				UserDefaults.standard.synchronize()
			})
		} else {
			CloudKitManager.container.fetchUserRecordID { (recordId, error) -> Void in
				guard let recId = recordId else {
					completion?(nil, error as NSError?)
					return
				}
				CloudKitManager.publicDB.fetch(withRecordID: recId, completionHandler: { (record, error) -> Void in
					guard let rec = record else {
						completion?(nil, error as NSError?)
						return
					}
					let usr = User(record: rec, recordId: recordId!)
					User.currentUser = usr
					User.currentUser!.localSave()
					completion?(usr, nil)
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

	func getTeams(_ completion:((_ teams: [Team], _ local: Bool, _ error: NSError?) -> Void)? = nil) {
		if let teamsData = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.teamUserKey) as? Data {
			let teams = NSKeyedUnarchiver.unarchiveObject(with: teamsData) as? [Team]
			completion?(teams!, true, nil)
		}
		getReferences(teams, completion: { (results: [Team], error) -> Void in
			let data = NSKeyedArchiver.archivedData(withRootObject: results)
			UserDefaults.standard.set(data, forKey:Constants.UserDefaultsKeys.teamUserKey)
			UserDefaults.standard.synchronize()
			completion?(results, false, error)
		})
	}

	func getColors(_ completion:((_ teamColor: [UserTeamColor], _ error: NSError?) -> Void)? = nil) {
		getReferences(teamColor, completion: { (results: [UserTeamColor], error) -> Void in
			completion?(results, error)
		})
	}

	func getTeamColors(_ team: Team,
	                   completion: ((_ tColor: UIColor?, _ uTColor: UserTeamColor?, _ error: NSError?) -> Void)? = nil) {
		self.getColors { (teamColor, error) -> Void in
            if let tC = teamColor.first(where: { (utColor) -> Bool in
                return utColor.teamName == team.recordId.recordName
            }) {
                completion?(tC.getUTColor(), tC, nil)
            } else {
                completion?(nil, nil, error)
            }
		}
	}

	func updateColorForTeam(_ team: Team, color: UIColor, colorSeed: CGFloat, completion:(() -> Void)? = nil) {
		self.getTeamColors(team) { (_, userTeamColor, error) in
			guard let userTeamColor = userTeamColor, error == nil else {
				return
			}
			userTeamColor.color = NSKeyedArchiver.archivedData(withRootObject: color)
			userTeamColor.colorSeed = colorSeed
			userTeamColor.publicSave({ (_, _) in
				team.publicSave()
				completion?()
			})
		}
	}

    func addTeam(_ team: Team, color: UIColor, colorSeed: CGFloat, completion: (() -> Void)? = nil) {

		team.users.append(CKReference(record: self.toRecord(), action: .none))
		teams.append(CKReference(record: team.toRecord(), action: .none))
		UserTeamColor.create(team,
		                     colorSeed: colorSeed,
		                     color: color,
		                     completion: {(utColor: UserTeamColor?, error: NSError?) in
            guard let utColor = utColor else {
                print(error ?? "nil error")
                return
            }
			self.teamColor.append(CKReference(record: utColor.toRecord(), action: .none))
			self.saveBulk([utColor.toRecord(), team.toRecord()], completion:  completion)
			self.localSave()
		})
	}

    func removeTeam(recordID: CKRecordID) {
        teams.remove(at: (teams.index(where: { (ref: CKReference) -> Bool in
            return recordID == ref.recordID
        }))!)
        self.localSave()
        self.updateRecord()
    }
}
