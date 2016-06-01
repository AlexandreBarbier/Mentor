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
    
    override class func recordType() -> String {
        return "UserTeamColor"
    }
    
    class func create(team:Team, colorSeed:CGFloat, color:UIColor, completion:((utColor:UserTeamColor, error:NSError?)->Void)? = nil) -> UserTeamColor {
        
        let utColor: UserTeamColor = {
            $0.colorSeed = colorSeed
            $0.teamName = team.recordId.recordName
            $0.color = NSKeyedArchiver.archivedDataWithRootObject(color)
            return $0
        }(UserTeamColor())
        
        utColor.publicSave({ (record, error) -> Void in
            utColor.record = record
            completion?(utColor: utColor, error: error)
        })
        
        return utColor
    }
    
    func getColor() -> UIColor {
        return NSKeyedUnarchiver.unarchiveObjectWithData(color) as! UIColor
    }
}
