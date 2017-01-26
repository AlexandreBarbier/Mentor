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
    var drawingPath: CKReference!

    override class func recordType() -> String {
        return "Points"
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        do {
            let dico: [String: AnyObject]?
            if #available(iOS 9.0, *) {
                dico = try aDecoder.decodeTopLevelObject(forKey: "root") as? [String: AnyObject]
            } else {
                dico = aDecoder.decodeObject(forKey: "root") as? [String: AnyObject]
            }
            guard let dictionary = dico else {
                return
            }
            self.parse(with: dictionary)
            if let recId = aDecoder.decodeObject(forKey: "recordId") as? CKRecordID {
                recordId = recId
            }
            if let rec = aDecoder.decodeObject(forKey: "record") as? CKRecord {
                record = rec
            }
        } catch {
            return
        }

    }

    required init() {
        super.init()
    }

    func parse(with dictionary: [String: AnyObject]) {
        if let xVal = dictionary["x"] as? NSNumber {
            x = xVal
        }
        if let yVal = dictionary["y"] as? NSNumber {
            y = yVal
        }
        if let pos = dictionary["position"] as? NSNumber {
            position = Int(pos)
        }
        if let dPath = dictionary["drawingPath"] as? CKReference {
            drawingPath = dPath
        }
    }

    required convenience init(dictionary: [String : AnyObject]) {
        self.init()
        self.parse(with: dictionary)
    }

    required convenience init(record rec: CKRecord, recordId rId: CKRecordID) {
        let keys = rec.allKeys()
        let dictionary = rec.dictionaryWithValues(forKeys: keys)
        self.init(dictionary: dictionary as [String: AnyObject])
        recordId = rId
        record = rec
    }

    class func create(_ x: NSNumber, y: NSNumber, position: Int? = nil, save: Bool, dPath: DrawingPath) -> Point {
        let point: Point = {
            $0.x = x
            $0.y = y
            $0.drawingPath = CKReference(record: dPath.record, action: .deleteSelf)
            if let position = position {
                $0.position = position
            }
            return $0
        }(Point())
        if save {
            point.updateRecord()
        }
        return point
    }

    class func createBatch(_ points: [CGPoint], dPath: DrawingPath) -> (records: [CKRecord], points: [Point]) {
        var pointsRecord = [CKRecord]()
        var batchPoints = [Point]()

        for (index, point) in points.enumerated() {
            let po = Point.create(NSNumber(value: Float(point.x) as Float),
                                  y: NSNumber(value: Float(point.y) as Float),
                                  position: index,
                                  save: false,
                                  dPath: dPath)
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
