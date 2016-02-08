//
//  CBFirebase.swift
//  Collabboard
//
//  Created by Alexandre barbier on 08/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit
import Firebase

struct FirebaseKey {
    static let red = "r"
    static let green = "g"
    static let blue = "b"
    static let pathName = "pn"
    static let x = "x"
    static let y = "y"
    static let points = "po"
    static let delete = "del"
    static let marker = "mark"
    static let lineWidth = "lw"
    static let drawingUser = "du"
    static let undeletable = "undeletable"
}

let cbFirebase = CBFirebase()

class CBFirebase: NSObject {
    var drawing : Firebase!
    var delete : Firebase!
    var background : Firebase!
    var users : Firebase!
    
    var firebaseDrawingObserverHandle : UInt = 0
    var firebaseDeleteObserverHandle : UInt = 0
    var firebaseBackgroundObserverHandle : UInt = 0
    
    var project : Project! {
        didSet {
            self.initBackground(self.project)
            self.initDrawing(self.project)
            self.initDelete(self.project)
        }
    }
    
    var team : Team! {
        didSet {
            self.initUser(self.team)
        }
    }
    
    func setupWithTeam(team:Team, project:Project) {
        self.team = team
        self.project = project
    }
    
    func initUser(team:Team) {
        if let users = users {
            users.removeObserverWithHandle(firebaseDrawingObserverHandle)
        }
        users = Firebase(url: "\(Constants.NetworkURL.firebase.rawValue)\(project.recordName)/\(team.recordId.recordName)/")
    }
    
    func connectUserToTeam() {
        
    }
    
    func initDrawing(project:Project) {
        if let drawing = drawing {
            drawing.removeObserverWithHandle(firebaseDrawingObserverHandle)
        }
        drawing = Firebase(url: "\(Constants.NetworkURL.firebase.rawValue)\(project.recordName)/drawing/")
    }
    
    func initDelete(project:Project) {
        if let delete = delete {
            delete.removeObserverWithHandle(firebaseDeleteObserverHandle)
        }
        delete = Firebase(url: "\(Constants.NetworkURL.firebase.rawValue)\(project.recordName)/delete")
    }
    
    func initBackground(project:Project) {
        if let background = background {
            background.removeObserverWithHandle(firebaseBackgroundObserverHandle)
        }
        background = Firebase(url: "\(Constants.NetworkURL.firebase.rawValue)\(project.recordName)/back")
    }
}
