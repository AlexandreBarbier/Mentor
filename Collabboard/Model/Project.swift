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

class Project : ABModelCloudKit {
    var infos = ""
    var name = ""
    var background : CKAsset!
    var recordName = ""
    var drawing : CKReference!
    var width: NSNumber!
    var height: NSNumber!
    var editable = true
    
    override class func recordType() -> String {
        return "Projects"
    }
    
    override var description :String {
        get {
            return "Project \(self.name)"
        }
    }
}

// MARK: - Creation
extension Project {
    
    class func create(name:String, team:Team, completion:((project:Project, team:Team) -> Void)? = nil) -> Project {
        let project = Project()
        project.name = name
        project.recordName = project.recordId!.recordName
        let drawing = Drawing.create(project, save:false)
        project.drawing = CKReference(record: drawing.record!, action: .DeleteSelf)
        let size = UIScreen.mainScreen().bounds.size
        project.width = NSNumber(float: Float(size.width))
        project.height = NSNumber(float: Float(size.height))
        team.projects.append(CKReference(record: project.toRecord(), action: CKReferenceAction.None))
        project.saveBulk([drawing.toRecord(), team.toRecord()]) { () -> Void in
            completion?(project: project, team:team)
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
    class func getLastOpen() -> (project:Project?, team:Team?)? {
        if let teamProjectData = NSUserDefaults.standardUserDefaults().arrayForKey(Constants.UserDefaultsKeys.lastOpenedProject) {
            let project = NSKeyedUnarchiver.unarchiveObjectWithData(teamProjectData[0] as! NSData) as? Project
            let team = NSKeyedUnarchiver.unarchiveObjectWithData(teamProjectData[1] as! NSData) as? Team
            return (project,team)
        }
        return nil
    }
    
    /**
     save the last opened project
     
     - parameter team: the associated team
     */
    func setLastOpenForTeam(team:Team) {
        let projectData = NSKeyedArchiver.archivedDataWithRootObject(self)
        let teamData = NSKeyedArchiver.archivedDataWithRootObject(team)
        NSUserDefaults.standardUserDefaults().setObject([projectData,teamData], forKey:Constants.UserDefaultsKeys.lastOpenedProject)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getDrawing(completion:(drawing:Drawing?, error:NSError?) -> Void) {
        super.getReferences([drawing!],completion: { (results:[Drawing], error) -> Void in
            completion(drawing: results.first, error: error)
        })
    }
    
    class func get(name:String , completion:(project:Project?, error:NSError?)-> Void) {
        Project.getRecord("recordName=\'\(name)\'") { (record, error) in
            guard let record = record else {
                completion(project: nil, error: error)
                return
            }
            let project = Project(record: record, recordId: record.recordID)
            completion(project: project, error: nil)
        }
    }
    
    func saveBackground(image:UIImage, completion:() -> Void) {
        let docDirPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        let filePath =  "\(docDirPath)/\(self.recordName).png"
        let myData =  UIImagePNGRepresentation(image)
        myData?.writeToFile(filePath, atomically: true)
        self.background = CKAsset(fileURL:NSURL(fileURLWithPath:filePath))
        self.publicSave { (record, error) -> Void in
            completion()
        }
    }
    
}