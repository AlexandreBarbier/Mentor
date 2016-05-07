//
//  UserTeamColor.swift
//  Mentor
//
//  Created by Alexandre barbier on 15/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit
import ABModel

class UserTeamColor: ABModelCloudKit {
    var teamName:String = ""
    var color:NSData!
    var colorSeed : CGFloat = 1.0
    
    class func create(team:Team, colorSeed:CGFloat, color:UIColor, completion:((utColor:UserTeamColor, error:NSError?)->Void)? = nil) -> UserTeamColor {
        let utColor = UserTeamColor()
        utColor.colorSeed = colorSeed
        utColor.teamName = team.recordId.recordName
        utColor.color = NSKeyedArchiver.archivedDataWithRootObject(color)
        utColor.publicSave({ (record, error) -> Void in
            utColor.record = record
            completion?(utColor: utColor,error: error)
        })
        
        return utColor
    }
    
    func getColor() -> UIColor {
        return NSKeyedUnarchiver.unarchiveObjectWithData(color) as! UIColor
    }
}
