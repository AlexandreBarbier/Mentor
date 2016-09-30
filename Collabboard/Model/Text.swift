//
//  Text.swift
//  Collabboard
//
//  Created by Alexandre barbier on 19/06/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit
import ABModel
import CloudKit

class Text: ABModelCloudKit {
    var text : String = ""
    var x: NSNumber = 0.0
    var y: NSNumber = 0.0
    
    
    override class func recordType() -> String {
        return "Texts"
    }
    
    class func create(_ drawing:Drawing, x: NSNumber, y: NSNumber, text:String,  position:Int? = nil, save: Bool) -> Text {
        let txt : Text = {
            drawing.texts.append(CKReference(record: $0.record, action: CKReferenceAction.none))
            $0.x = x
            $0.y = y
            $0.text = text
            $0.updateRecord()
            return $0
        }(Text())
        drawing.publicSave({ (record, error) -> Void in
            
        })
        return txt
    }
}
