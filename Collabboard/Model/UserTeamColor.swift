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
    var color:Data!
    var colorSeed : CGFloat = 1.0
    
    override class func recordType() -> String {
        return "UserTeamColor"
    }
    
	@discardableResult class func create(_ team:Team, colorSeed:CGFloat, color:UIColor, completion:((_ utColor:UserTeamColor, _ error:NSError?)->Void)? = nil) -> UserTeamColor {
        
        let utColor: UserTeamColor = {
            $0.colorSeed = colorSeed
            $0.teamName = team.recordId.recordName
            $0.color = NSKeyedArchiver.archivedData(withRootObject: color)
            return $0
        }(UserTeamColor())
        
        utColor.publicSave({ (record, error) -> Void in
            utColor.record = record
            completion?(utColor, error as NSError?)
        })
        
        return utColor
    }
    
    func getColor() -> UIColor {
        return NSKeyedUnarchiver.unarchiveObject(with: color) as! UIColor
    }
}
