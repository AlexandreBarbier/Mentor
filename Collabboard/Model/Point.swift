//
//  Point.swift
//  Mentor
//
//  Created by Alexandre barbier on 08/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit
import ABModel
import CloudKit


class Point: ABModelCloudKit {
    var x: NSNumber = 0.0
    var y: NSNumber = 0.0
    var position = 0
    var drawingPath : CKReference!
    
    override class func recordType() -> String {
        return "Points"
    }
    
    class func create(x:NSNumber, y : NSNumber, position: Int? = nil, save:Bool, dPath : DrawingPath) -> Point {
        let po : Point = Point()
        po.x = x
        po.y = y
        po.drawingPath = CKReference(record: dPath.record, action: .DeleteSelf)
        if let position = position {
            po.position = position
        }
        po.updateRecord()

        return po
    }
    
    class func createBatch(points:[CGPoint], dPath : DrawingPath) -> (records:[CKRecord],points:[Point]) {
        var pointsRecord = [CKRecord]()
        var batchPoints = [Point]()
        var i = 0
        for point in points {
            let po = Point.create(NSNumber(float:Float(point.x)), y: NSNumber(float:Float(point.y)), position: i, save: false, dPath:dPath)
            i += 1
            batchPoints.append(po)
            pointsRecord.append(po.record!)
            
        }

        return (pointsRecord, batchPoints)
    }
}
