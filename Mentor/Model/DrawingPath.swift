//
//  DrawingPath.swift
//  Mentor
//
//  Created by Alexandre barbier on 10/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit
import ABModel
import CloudKit

class DrawingPath: ABModelCloudKit {
    var points : [CKReference] = [CKReference]()
    var color : NSData!
    var user = ""
    var lineWidth : CGFloat = 2.0
    var pen = true
    
    override class func recordType() -> String {
        return "DrawingPath"
    }
    
    override func ignoreKey(key: String, value: AnyObject) -> Bool {
        if key == "points" {
            for ref : CKReference in value as! [CKReference] {
                self.points.append(ref)
            }
            return true
        }
        return false
    }
    
    class func create(drawing:Drawing, completion:((success:Bool) -> Void)?) -> DrawingPath {
        let drawingPath = DrawingPath()

        drawing.paths.append(CKReference(record: drawingPath.record, action: CKReferenceAction.None))
        if let currentUser = KCurrentUser {
            drawingPath.user = currentUser.recordId.recordName
        }
        drawing.publicSave({ (record, error) -> Void in
            if let completion = completion {
                completion(success: error == nil)
            }
        })

        return drawingPath
    }
    
    func localKey()-> String { return "\(self.recordId.recordName)points" }
    
    override func remove() {
        super.remove()
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: localKey())
    }
    
    func getPoints(completion:(points:[Point], error:NSError?) -> Void) {
        if let pointsData = NSUserDefaults.standardUserDefaults().objectForKey(localKey()) as? NSData {
            let archivedPoints =  NSKeyedUnarchiver.unarchiveObjectWithData(pointsData) as? [Point]
            completion(points: archivedPoints!, error: nil)
        }
        else {
            super.getReferences(points, completion: { (results:[Point], error) -> Void in
                let data = NSKeyedArchiver.archivedDataWithRootObject(results)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey:self.localKey())
                completion(points: results, error: error)
            })
        }
    }
    
    func localSave(point:[Point]) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(point)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey:localKey())
    }
    
}
