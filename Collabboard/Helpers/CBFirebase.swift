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
    static let xKey = "x"
    static let yKey = "y"
    static let points = "po"
    static let text = "txt"
    static let delete = "del"
    static let marker = "mark"
    static let lineWidth = "lw"
    static let drawingUser = "du"
    static let undeletable = "undeletable"
}

let cbFirebase = CBFirebase()

class CBFirebase: NSObject {
    var drawing: FIRDatabaseReference!
    var delete: FIRDatabaseReference!
    var background: FIRDatabaseReference!
    var users: FIRDatabaseReference!

    var firebaseDrawingObserverHandle: UInt = 0
    var firebaseDeleteObserverHandle: UInt = 0
    var firebaseBackgroundObserverHandle: UInt = 0
    var firebaseUserObserverHandle: UInt = 0

    var project: Project! {
        didSet {
            initBackground(project)
            initDrawing(project)
            initDelete(project)
        }
    }

    var team: Team! {
        didSet {
            initUser(team)
        }
    }

    func setupWithTeam(_ team: Team, project: Project) {
        self.project = project
        self.team = team
    }

    func initUser(_ team: Team) {
        if let users = users {
            if let cbUsers = cbFirebase.users {
                cbUsers.updateChildValues([User.currentUser!.recordId.recordName: false])
            }
            users.removeObserver(withHandle: firebaseUserObserverHandle)
        }
        users = FIRDatabase.database().reference(withPath: "\(project.recordName)/\(team.recordId.recordName)/")
    }

    func initDrawing(_ project: Project) {
        if let drawing = drawing {
            drawing.removeObserver(withHandle: firebaseDrawingObserverHandle)
        }
        drawing = FIRDatabase.database().reference(withPath: "\(project.recordName)/drawing/")
    }

    func initDelete(_ project: Project) {
        if let delete = delete {
            delete.removeObserver(withHandle: firebaseDeleteObserverHandle)
        }
        delete = FIRDatabase.database().reference(withPath: "\(project.recordName)/delete")
    }

    func initBackground(_ project: Project) {
        if let background = background {
            background.removeObserver(withHandle: firebaseBackgroundObserverHandle)
        }
        background = FIRDatabase.database().reference(withPath: "\(project.recordName)/back")
    }
}
