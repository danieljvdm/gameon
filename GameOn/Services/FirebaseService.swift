//
//  FirebaseService.swift
//  GameOn
//
//  Created by Daniel on 5/15/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import Firebase
import FirebaseRxSwiftExtensions
import RxSwift

struct FirebaseService {
    private let baseUrl = "https://game-on-app.firebaseio.com"
    let rootRef: Firebase
    let usersRef: Firebase
    let userRef: Firebase
    let chatsRef: Firebase
    var uid: String {
        return rootRef.authData.uid
    }

    init() {
        rootRef = Firebase(url: baseUrl)
        usersRef = rootRef.childByAppendingPath("users")
        userRef = usersRef.childByAppendingPath(rootRef.authData.uid)
        chatsRef = rootRef.childByAppendingPath("chats")
    }
}