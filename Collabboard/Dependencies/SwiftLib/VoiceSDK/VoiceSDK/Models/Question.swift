//
//  Question.swift
//  Voice
//
//  Created by Alexandre barbier on 09/10/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import Foundation
import ABModel

public enum QuestionType : String {
    case Binary = "binary"
    case Star = "stars"
    case Number = "number"
    case Multiple = "multiple"
    case None = "none"
    
    init(val:String) {
        switch val {
        case  QuestionType.Binary.rawValue:
            self = QuestionType.Binary
        case QuestionType.Star.rawValue :
            self = QuestionType.Star
        case QuestionType.Number.rawValue :
            self = QuestionType.Number
        case QuestionType.Multiple.rawValue :
            self = QuestionType.Multiple
        default :
            self = QuestionType.None
        }
    }
}

public class QuestionVoted : ABModel {

    public override var description : String {
        get {
            return "\nquestionVote {\n\tdate : \(self.date)\n\tvote : \(self.vote)\n\tpublic : \(self.isPublic)\n}"
        }
    }
    public var timestamp = 0
    public var vote = -1
    public var isPublic = true
    public var date = NSDate()
    
}

public class Question : ABModel {
   public override var description : String {
        get {
            return "\nquestion {\n\tid : \(self.id)\n\tquestion type : \(self.type)\n\tquestion : \(self.question)\n\tuser id : \(self.user.id)\n\tchoices : \(self.choices)\n}"
        }
    }
    public var id:Int = -1
    public var coins = 0
    public var question : String = ""
    public var img : UIImage?
    public var pending:Int32 = -1
    public var date = NSDate()
    public var foursquare = [:]
    public var commentsPreview = [Comment()]
    public var channel = -1
    public var replies = -1
    public var flags = -1
    public var voted = QuestionVoted()
    public var user = User()
    public var reposted = false
    public var choices = [Choice()]
    public var geo = Geo()
    public var image = ""
    public var featured = false
    public var views = -1
    public var comments = -1
    public var shares = Dictionary<String, AnyObject>()
    public var purchased = false
    public var client = -1
    public var votes = -1
    public var lang = ""
    public var tags = [Tag()]
    public var reposts = -1
    public var type : String = "" {
        didSet {
            if type != questionType.rawValue {
                questionType = QuestionType(val: type)
            }
        }
    }
    public var questionType : QuestionType = QuestionType.None {
        didSet {
            if type != questionType.rawValue {
                type = questionType.rawValue
            }
        }
    }
    public var media : Media = Media() {
        didSet {
            if media.mediaType == MediaType.ImageType {
                self.img = UIImage(url: NSURL(string: media.link)!)
            }
        }
    }

    public override func replaceKey(key: String) -> String {
        switch key {
        case "comments_preview":
            return "commentsPreview"
        default:
            return ""
        }
    }
}