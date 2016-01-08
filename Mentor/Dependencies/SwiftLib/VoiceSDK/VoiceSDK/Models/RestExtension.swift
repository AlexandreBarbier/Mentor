//
//  RestExtension.swift
//  Voice
//
//  Created by Alexandre barbier on 09/10/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import Foundation

//Connection
public extension Question {
    
    public class func getQuestion(questionId: Int, completion:(local:Bool,
        success:Bool,
        question:Question?,
        error: NSError?) -> Void) {
            VoiceRequest.get("questions/\(questionId)" ,
                parameters: nil,
                cached: false,
                requireAuth: false,
                completion: {
                    (local: Bool,
                    success: Bool,
                    object: AnyObject?,
                    error: NSError?) in
                    if  (error == nil) {
                        var question = Question(dictionary: object! as Dictionary <String, AnyObject>)
                        completion(local: local, success: success, question: question, error: error)
                    }
            })
    }
    
    public class func getTranslation(questionId: Int, completion:(local:Bool,
        success:Bool,
        question:Question?,
        error:NSError? ) -> Void) {
            
            VoiceRequest.get("questions/\(questionId)",
                parameters: ["translate":"fr"],
                cached: false,
                requireAuth: true,
                completion: {
                    (local: Bool, success: Bool, object:AnyObject?, error: NSError?) in
                    var question = Question(dictionary: object! as Dictionary <String, AnyObject>)
                    completion (local: local, success: success, question: question, error: error)
            })
    }
    
    public class func getQuestionForChannelId(channelId:Int,
        offset:Int,
        limit:Int,
        completion:(success:Bool, local:Bool, questions:Array<Question>?, error:NSError?) -> Void) {
            VoiceRequest.get("channels/\(channelId)", parameters: ["offset":offset,"limit":limit], cached: false, requireAuth: true) {
                (local, success, object, error) -> Void in
                if success {
                    var questions = [Question]()
                    for dico in object as [Dictionary <String, AnyObject>] {
                        var question = Question(dictionary:dico)
                        questions.append(question)
                    }
                    completion(success: success, local: local, questions: questions, error: nil)
                }
                else {
                    completion(success: success, local: local, questions: nil, error: error)
                }
            }
    }
    
    public class func getCommentsOnQuestion(questionId:Int,
        sort:String,
        offset:Int,
        limit:Int,
        completion:(success:Bool, local:Bool, comments:Array<Comment>?, error:NSError?)->Void) {
            
            VoiceRequest.get("questions/\(questionId)/comments", parameters: ["offset":offset,"limit":limit,"sort":sort], cached: false, requireAuth: true, completion:{ (local: Bool, success: Bool, object: AnyObject?, error: NSError?) in
                if success {
                    var result = Array<Comment>()
                    var tab = object as Array<Dictionary<String, AnyObject>>
                    for comment in tab {
                        result.append(Comment(dictionary: comment))
                    }
                    completion(success: success,local: local,comments: result,error: nil)
                }
                else {
                    completion(success: success,local: local,comments: nil,error: error)
                }
                
            })
    }
    
    public class func voteOnQuestion(questionId : Int, vote:Float, completion:(success:Bool, error:NSError?)->Void) {

        VoiceRequest.post("questions/\(questionId)/vote/\(vote)",
                    parameters:nil,
                        cached:false,
                   requireAuth:true,
                    completion:{(local:Bool,
                       success:Bool,
                        object:AnyObject?,
                         error: NSError?) in
                        completion (success:true, error:error)
        })
    }
    
}

//Connection
public extension User {
    
    public class func connectWithCredential(email:String, password:String, completion:
        (local: Bool,
        success: Bool,
        object: AnyObject?,
        error: NSError?) -> Void) {
            VoiceRequest.post("oauth/official_app",
                parameters: ["email":email, "password":password], cached: false, requireAuth: false, completion: {(local: Bool, success: Bool, object: AnyObject?, error: NSError?) in
                    completion(local: local, success: success, object: object, error: error)
            })
    }
    
    public class func create(email:String, password:String, username:String, completion:(local: Bool, success: Bool, object:AnyObject?, error:NSError?) -> Void) {
        VoiceRequest.post("account", parameters: ["email": email, "password":password,"username":username], cached: false, requireAuth: false) { (local, success, object, error) -> Void in
            completion(local: local, success: success, object: object, error: error)
        }
    }
    
    public class func emailAlreadyTaken(email:String, completion:(success:Bool, error:NSError?) -> Void) {
        VoiceRequest.get("voice/email_available?email=\(email)", parameters: nil, cached: false, requireAuth: false) { (local, success, object, error) -> Void in
            if success {
                completion(success: object as Bool, error:nil)
            }
            else {
                completion(success: false, error: error)
            }
        }
    }
    
    public class func getAccount(completion:(success:Bool, user:User?, error:NSError?) -> Void) {
        VoiceRequest.get("account", parameters: nil, cached: false, requireAuth: true) { (local, success, object, error) -> Void in
            if success {
                var usr = User(dictionary: object! as Dictionary <String, AnyObject>)
                completion (success: true, user: usr, error: nil)
            }
            else {
                completion (success: false, user: nil, error: error)
            }
            
        }
    }
}

//Rest
public extension User {
    
    public class func getUser(userId :String,
        completion:
        (local: Bool,
        success: Bool,
        object: User?,
        error: NSError?) -> Void) {
            VoiceRequest.get("users/\(userId)", parameters: [:], cached: false, requireAuth: true, completion: {
                (local: Bool, success: Bool, object: AnyObject?, error: NSError?) in
                var user = User(dictionary: object! as Dictionary <String, AnyObject>)
                completion(local: local, success: success, object: user, error: error)
            })
    }
}