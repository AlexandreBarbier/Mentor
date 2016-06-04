//
//  CBFirebase.swift
//  Collabboard
//
//  Created by Alexandre barbier on 08/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit
import FirebaseDatabase

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
    var drawing : FIRDatabaseReference!
    var delete : FIRDatabaseReference!
    var background : FIRDatabaseReference!
    var users : FIRDatabaseReference!
    
    var firebaseDrawingObserverHandle : UInt = 0
    var firebaseDeleteObserverHandle : UInt = 0
    var firebaseBackgroundObserverHandle : UInt = 0
    var firebaseUserObserverHandle : UInt = 0
    
    var project : Project! {
        didSet {
            initBackground(project)
            initDrawing(project)
            initDelete(project)
        }
    }
    
    var team : Team! {
        didSet {
            initUser(team)
        }
    }
    
    func setupWithTeam(team:Team, project:Project) {
        self.project = project
        self.team = team
    }
    
    func initUser(team:Team) {
        if let users = users {
            users.removeObserverWithHandle(firebaseUserObserverHandle)
        }
        users = FIRDatabase.database().referenceWithPath("\(project.recordName)/\(team.recordId.recordName)/")
    }
    
    func initDrawing(project:Project) {
        if let drawing = drawing {
            drawing.removeObserverWithHandle(firebaseDrawingObserverHandle)
        }
        drawing = FIRDatabase.database().referenceWithPath("\(project.recordName)/drawing/")
    }
    
    func initDelete(project:Project) {
        if let delete = delete {
            delete.removeObserverWithHandle(firebaseDeleteObserverHandle)
        }
        delete = FIRDatabase.database().referenceWithPath("\(project.recordName)/delete")
    }
    
    func initBackground(project:Project) {
        if let background = background {
            background.removeObserverWithHandle(firebaseBackgroundObserverHandle)
        }
        background = FIRDatabase.database().referenceWithPath("\(project.recordName)/back")
    }
}
