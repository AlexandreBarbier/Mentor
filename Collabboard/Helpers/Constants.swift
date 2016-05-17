//
//  Constants.swift
//  Mentor
//
//  Created by Alexandre barbier on 11/12/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import UIKit

class Constants {
    enum NetworkURL : String {
        //TODO: Switch firebase project
        case firebase = "https://project-4506251654366768501.firebaseio.com/"
        //case firbase = "https://mentor1.firebaseio.com/"
    }
    
    struct UserDefaultsKeys {
        static let currentUser = "currentUser"
        static let teamUserKey = "teams"
        static let teamProjects = "teamProjects"
        static let lastOpenedProject = "lastOpenedProject"
    }
}
