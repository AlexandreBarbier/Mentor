//
//  User.swift
//  Voice
//
//  Created by Alexandre barbier on 09/10/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import ABModel

public class User: ABModel {
    public var id = -1
    public var username = ""
    //public var level = -1
    public var bio = ""
    public var counters = Counter()
    public var flags = -1;
    public var phone = ""
    public var auth = 0
    public var name = ""
    public var facebookId = -1
    public var twitterId = -1
    public var twitterProfile = ""
    public var facebookProfile = ""
    public var image = ""
    public var featured = false
    public var emailVerified = false
    public var facebookOpengraph = false
    public var customizer = false
    public var email = ""
    public var preferedChannels = ""
    public var coins = 0
    public var following = [User]()
    public var credits = 0
    public var can_earn_coins = false
    public override var description : String {
        get {
            return "\nuser {\n\tid : \(self.id)\n\tusername : \(self.username)\n\tname : \(self.name)\n}"
        }
    }
    
    public override func replaceKey(key: String) -> String  {
        switch key {
            
        case "facebook_id":
            return "facebookId"
            
        case "twitter_id":
            return "twitterId"
            
        case "twitter_profile":
            return "twitterProfile"
            
        case "facebook_profile":
            return "facebookProfile"
            
        case "email_verified":
            return "emailVerified"
            
        case "facebook_opengraph":
            return "facebookOpengraph"
            
        default:
            return ""
        }
    }
    
}
