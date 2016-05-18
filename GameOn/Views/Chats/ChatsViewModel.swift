//
//  FriendsViewModel.swift
//  GameOn
//
//  Created by Daniel on 5/16/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//
import Firebase
import RxSwift
import FirebaseRxSwiftExtensions

class ChatsViewModel: ViewModelType {
    var friends = Variable<[User]>([])
    
    init(){
//        FirebaseService.Constants.usersRef.observeSingleEventOfType(.Value) { (snapshot: FDataSnapshot!) in
//            for child in snapshot.children {
//                let uid = child.key
//                let childSnapshot = snapshot.childSnapshotForPath(uid)
//                let username = childSnapshot.value["username"] as! String
//                let fullName = childSnapshot.value["fullName"] as! String
//                let friend = User(uid: uid, username: username, fullName: fullName)
//                self.friends.value.append(friend)
//            }
//        }
        
//        FirebaseService.Constants.usersRef.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
//            let uid = snapshot.key
//            let username = snapshot.value["username"] as! String
//            let fullName = snapshot.value["fullName"] as! String
//            let friend = User(uid: uid, username: username, fullName: fullName)
//            self.friends.value.append(friend)
//        }
    }
}