//
//  User.swift
//  GameOn
//
//  Created by Daniel on 5/16/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let username: String?
    let fullName: String?
    
    init(uid: String, username: String? = nil, fullName: String? = nil){
        self.uid = uid
        self.username = username
        self.fullName = fullName
    }
}