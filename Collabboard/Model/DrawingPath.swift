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
    var color : Data!
    var user = ""
    var lineWidth : CGFloat = 2.0
    var pen = true
    
    override class func recordType() -> String {
        return "DrawingPath"
    }
    
    override func ignoreKey(_ key: String, value: AnyObject) -> Bool {
        if key == "points" {
            for ref : CKReference in value as! [CKReference] {
                self.points.append(ref)
            }
            return true
        }
        return false
    }
    
    class func create(_ drawing:Drawing, completion:((_ success:Bool, _ dPath:DrawingPath) -> Void)?) -> DrawingPath {
        let drawingPath : DrawingPath = {
            drawing.paths.append(CKReference(record: $0.record, action: CKReferenceAction.none))
            if let currentUser = User.currentUser {
                $0.user = currentUser.recordId.recordName
            }
            return $0
        }(DrawingPath())

        drawing.publicSave({ (record, error) -> Void in
            if let completion = completion {
                completion(error == nil, drawingPath)
            }
        })
        return drawingPath
    }
    
    func localKey()-> String { return "\(self.recordId.recordName)points" }
    
    override func remove() {
        super.remove()
        let _ : UserDefaults = {
            $0.set(nil, forKey: localKey())
            $0.synchronize()
            return $0
        } (UserDefaults.standard)
        
    }
    
    class func removeWithName(_ name:String) {
        let k = CKRecordID(recordName: name)
        super.removeRecordId(k)
    }
    
    func getPoints(_ completion:((_ points:[Point], _ error:NSError?) -> Void)? = nil) {
        if let pointsData = UserDefaults.standard.object(forKey: localKey()) as? Data {
            if let archivedPoints =  NSKeyedUnarchiver.unarchiveObject(with: pointsData) as? [Point] {
                completion?(archivedPoints, nil)
            }
        }
        else {
            super.getReferences(points, completion: { (results:[Point], error) -> Void in
                self.localSave(results)
                completion?(results, error)
            })
        }
    }
    
    func localSave(_ point:[Point]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: point)
        let _ : UserDefaults = {
            $0.set(data, forKey:localKey())
            $0.synchronize()
            return $0
        } (UserDefaults.standard)
        
    }
}
