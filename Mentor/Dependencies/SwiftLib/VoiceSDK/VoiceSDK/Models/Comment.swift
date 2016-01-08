//
//  Comment.swift
//  Voice
//
//  Created by Alexandre barbier on 09/10/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import Foundation
import ABModel

public class Comment: ABModel {
   public  override var description : String {
        get {
            return "\ncomment : {\n\tid : \(self.id)\n\tmessage : \(self.message)\n\tuser id : \(self.user.id)\n}"
        }
    }
    
    public var user = User()
    public var message = ""
    public var userVote = 0
    public var id = -1
    public var likes = 0
    public var questionId = -1
    public var replies = 0
    public var date = NSDate()
    public var timestamp = NSDate()
    
    public override func replaceKey(key: String) -> String {
        switch key {
        case "user_vote_index":
            return "userVote"
            
        case "qid":
            return "questionId"
            
        default:
            return ""
            
        }
        
        
    }
    
}