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
    
    class func create(_ x: NSNumber, y: NSNumber, position:Int? = nil, save: Bool, dPath: DrawingPath) -> Point {
        let po : Point = {
            $0.x = x
            $0.y = y
            $0.drawingPath = CKReference(record: dPath.record, action: .deleteSelf)
            if let position = position {
                $0.position = position
            }
            return $0
        }(Point())
        if save {
            po.updateRecord()
        }
        return po
    }
    
    
    
    class func createBatch(_ points: [CGPoint], dPath: DrawingPath) -> (records: [CKRecord], points: [Point]) {
        var pointsRecord = [CKRecord]()
        var batchPoints = [Point]()
        
        for (index, point) in points.enumerated() {
            let po = Point.create(NSNumber(value: Float(point.x) as Float), y: NSNumber(value: Float(point.y) as Float), position: index, save: false, dPath:dPath)
            batchPoints.append(po)
            pointsRecord.append(po.record!)
        }
        let mapRecords = batchPoints.map { (p) -> CKRecord in
            return p.toRecord()
        }
        ABModelCloudKit.saveBulk(mapRecords, completion: nil)
        return (pointsRecord, batchPoints)
    }
}
