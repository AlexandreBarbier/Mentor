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
    var paths: [CKReference] = [CKReference]()
    var texts: [CKReference] = [CKReference]()
    override class func recordType() -> String {
        return "Drawing"
    }

    override func ignoreKey(_ key: String, value: AnyObject) -> Bool {
        if key == "paths" || key == "texts", let refs = value as? [CKReference] {
            for ref: CKReference in refs {
                if key == "paths" {
                    paths.append(ref)
                }
                if key == "texts" {
                    texts.append(ref)
                }
            }
            return true
        }
        return false
    }

    class func create(_ project: Project,
                      completion: ((_ success: Bool, _ drawing: Drawing) -> Void)? = nil,
                      save: Bool) -> Drawing {
        let drawing = Drawing()
        drawing.project = project.recordId!.recordName
        if save {
            drawing.updateRecord { (_, error) -> Void in
                completion?(error == nil, drawing)
            }
        }
        return drawing
    }

    func getTexts(_ completion:((_ text: Text?, _ error: NSError?) -> Void)? = nil) -> Void {
        let currentTexts = texts
        texts.removeAll()
        super.getReferences(currentTexts) { (results: Text?, error) in
            guard let result = results, error == nil  else {
                completion?(nil, error)
                return
            }
            self.texts.append(CKReference(recordID: result.recordId, action: .none))
            completion?(result, error)
        }
    }

    func getPaths(_ completion: ((_ path: DrawingPath, _ error: NSError?) -> Void)? = nil) {
        let currentPath = paths
        paths.removeAll()
        super.getReferences(currentPath, perRecordCompletion: { (results: DrawingPath?, error) -> Void in
            if let result = results {
                self.paths.append(CKReference(recordID: result.recordId, action: .none))
                completion?(result, error)
            }
        })
    }
}
