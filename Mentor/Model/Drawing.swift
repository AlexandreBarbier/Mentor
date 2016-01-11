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
    override class func recordType() -> String {
        return "Drawing"
    }
    
    override func ignoreKey(key: String, value: AnyObject) -> Bool {
        if key == "paths" {
            self.paths = [CKReference]()
            for ref : CKReference in value as! [CKReference] {
                self.paths.append(ref)
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
    
    func getPaths(completion:(path:DrawingPath, error:NSError?) -> Void) {
        super.getReferences(paths,perRecordCompletion:{ (results:DrawingPath?, error) -> Void in
            if let result = results {
                completion(path:result, error: error)
            }
        })
    }
}
