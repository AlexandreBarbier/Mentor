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
    
    func getDrawing(completion:(drawing:[Drawing], error:NSError?) -> Void) {
        super.getReferences([drawing!],completion: { (results:[Drawing], error) -> Void in
            completion(drawing: results, error: error)
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