//
//  Project.swift
//  Mentor
//
//  Created by Alexandre barbier on 07/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit
import ABModel
import CloudKit

class Project: ABModelCloudKit {
    var infos = ""
    var name = ""
    var background: CKAsset!
    var recordName = ""
    var drawing: CKReference!
    var width: NSNumber!
    var height: NSNumber!
    var editable = true

    override class func recordType() -> String {
        return "Projects"
    }

    override var description: String {
        return "Project \(self.name)"
    }
}

// MARK: - Creation
extension Project {

	@discardableResult class func create(_ name: String,
	                                     team: Team,
	                                     completion: ((_ project: Project, _ team: Team) -> Void)? = nil) -> Project {
        let project = Project()
        project.name = name
        project.recordName = project.recordId!.recordName
        let drawing = Drawing.create(project, save:false)
        project.drawing = CKReference(record: drawing.record!, action: .deleteSelf)
        let size = UIScreen.main.bounds.size
        project.width = NSNumber(value: Double(size.width) as Double)
        project.height = NSNumber(value: Double(size.height) as Double)
        team.projects.append(CKReference(record: project.toRecord(), action: CKReferenceAction.none))
        project.saveBulk([drawing.toRecord(), team.toRecord()]) { () -> Void in
            completion?(project, team)
        }
        return project
    }
}

// MARK: - Fetches
extension Project {
    /**
     get the last opened project
     
     - returns: the project and the associated team
     */
    class func getLastOpen() -> (project: Project?, team: Team?)? {
        if let teamProjectData = UserDefaults.standard.array(forKey: Constants.UserDefaultsKeys.lastOpenedProject)
            as? [Data] {
            let project = NSKeyedUnarchiver.unarchiveObject(with: teamProjectData[0]) as? Project
            let team = NSKeyedUnarchiver.unarchiveObject(with: teamProjectData[1]) as? Team
            return (project, team)
        }
        return nil
    }

    /**
     save the last opened project
     
     - parameter team: the associated team
     */
    func setLastOpenForTeam(_ team: Team) {
        let projectData = NSKeyedArchiver.archivedData(withRootObject: self)
        let teamData = NSKeyedArchiver.archivedData(withRootObject: team)
        let _: UserDefaults = {
            $0.set([projectData, teamData], forKey: Constants.UserDefaultsKeys.lastOpenedProject)
            $0.synchronize()
            return $0
        }(UserDefaults.standard)
    }

    func getDrawing(_ completion:((_ drawing: Drawing?, _ error: NSError?) -> Void)? = nil) {
		guard let drawing = drawing else {
			return
		}
        getReferences([drawing], completion: { (results: [Drawing], error) -> Void in
            completion?(results.first, error)
        })
    }

    class func get(_ name: String ,
                   completion: ((_ project: Project?, _ error: NSError?) -> Void)? = nil) {
        Project.getRecord("recordName=\'\(name)\'") { (record, error) in
            guard let record = record else {
                completion?(nil, error)
                return
            }
            let project = Project(record: record, recordId: record.recordID)
            completion?(project, nil)
        }
    }

    func saveBackground(_ image: UIImage, completion: (() -> Void)? = nil) {
        let docDirPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                             FileManager.SearchPathDomainMask.userDomainMask,
                                                             true).first!
        let filePath =  "\(docDirPath)/\(recordName).png"
        if let myData = UIImagePNGRepresentation(image) {
            try? myData.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
        }
        background = CKAsset(fileURL:URL(fileURLWithPath:filePath))
        publicSave { (_, _) -> Void in
            completion?()
        }
    }
}
