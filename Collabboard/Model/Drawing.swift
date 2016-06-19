//
//  Drawing.swift
//  Mentor
//
//  Created by Alexandre barbier on 09/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit
import ABModel
import CloudKit

class Drawing: ABModelCloudKit {
    
    var project = ""
    var paths : [CKReference] = [CKReference]()
    var texts : [CKReference] = [CKReference]()
    override class func recordType() -> String {
        return "Drawing"
    }
    
    override func ignoreKey(key: String, value: AnyObject) -> Bool {
        if key == "paths" {
            for ref : CKReference in value as! [CKReference] {
                paths.append(ref)
            }
            return true
        }
        if key == "texts" {
            for ref : CKReference in value as! [CKReference] {
                texts.append(ref)
            }
            return true
        }
        return false
    }
    
    class func create(project:Project, completion:((success:Bool,drawing:Drawing) -> Void)? = nil, save:Bool) -> Drawing {
        let drawing = Drawing()
        drawing.project = project.recordId!.recordName
        if save {
            drawing.updateRecord { (record, error) -> Void in
                completion?(success: error == nil, drawing: drawing)
            }
        }
        return drawing
    }
    
    func getTexts(completion:(text:Text, error:NSError?) -> Void) -> Void {
        let currentTexts = texts
        texts.removeAll()
        super.getReferences(currentTexts) { (results : Text?, error) in
            if let result = results {
                self.texts.append(CKReference(recordID: result.recordId, action: .None))
                completion(text:result, error: error)
            }
        }
    }
    
    func getPaths(completion:(path:DrawingPath, error:NSError?) -> Void) {
        let currentPath = paths
        paths.removeAll()
        super.getReferences(currentPath, perRecordCompletion:{ (results:DrawingPath?, error) -> Void in
            if let result = results {
                self.paths.append(CKReference(recordID: result.recordId, action: .None))
                completion(path:result, error: error)
            }
        })
    }
}
