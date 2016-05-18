//
//  ChatCoordinator.swift
//  GameOn
//
//  Created by Daniel on 5/14/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import Foundation
import UIKit
import FirebaseRxSwiftExtensions
import Firebase
import RxSwift
import JSQMessagesViewController

protocol ChatCoordinatorDelegate: class {
    
}

final class ChatCoordinator: CoordinatorType {
    var navCtrl: UINavigationController!
    var firebase: FirebaseService!
    weak var delegate: ChatCoordinatorDelegate?
    
    func start() {
        var vc = R.storyboard.chats.chatsVC()!
        vc.inject(ChatsViewModel())
        vc.delegate = self
        navCtrl.pushViewController(vc, animated: false)
    }
    
    func pushChatScreen(user: User) {
        let ref = firebase.userRef.childByAppendingPath("chats/\(user.uid)")
        ref.observeSingleEventOfType(.Value) { [unowned self] (snapshot: FDataSnapshot!) in
            
            var vc = R.storyboard.chats.chatVC()!
            
            var chatRef: Firebase!
            if snapshot.value is NSNull {
                chatRef = self.firebase.chatsRef.childByAutoId()
                chatRef.childByAppendingPath("typingIndicator").setValue([ref.authData.uid : false, user.uid : false])
                ref.setValue(["chatId" : chatRef.key])
                let ref2 = self.firebase.usersRef.childByAppendingPath("\(user.uid)/chats/\(self.firebase.uid)")
                ref2.setValue(["chatId" : chatRef.key])
                
            } else {
                chatRef = self.firebase.chatsRef.childByAppendingPath(snapshot.value.objectForKey("chatId") as! String)
            }
            
            let messagesRef = chatRef.childByAppendingPath("messages")
            
            
            let messages = Variable<[JSQMessage]>([])
            messagesRef.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
                let senderId = snapshot.value["senderId"] as! String
                let text = snapshot.value["text"] as! String
                messages.value.append(JSQMessage(senderId: senderId, displayName: "", text: text))
            }
            
            let typingRef = chatRef.childByAppendingPath("typingIndicator")
            typingRef.queryOrderedByValue().queryEqualToValue(true).observeEventType(.Value) { (snapshot: FDataSnapshot!) in
                if snapshot.childrenCount == 1 && snapshot.hasChild(self.firebase.uid) {
                    return
                }
                vc.showTypingIndicator = snapshot.childrenCount > 0
                vc.scrollToBottomAnimated(true)
            }
        
            vc.inject(ChatViewModel(user: user, messages: messages))
            vc.messageAdded = { text in
                let messageRef = messagesRef.childByAutoId()
                let message = ["senderId" : self.firebase.uid, "text": text]
                messageRef.setValue(message)
            }
            
            let userTypingref = typingRef.childByAppendingPath(self.firebase.uid)
            vc.typingChanged = { bool in
                userTypingref.setValue(bool)
            }
            userTypingref.onDisconnectRemoveValue()
            
            vc.senderId = self.firebase.uid
            vc.senderDisplayName = "Daniel"
            self.navCtrl.pushViewController(vc, animated: false)
        }
       
    }
    
    func pushFriendsScreen() {
        var vc = R.storyboard.chats.friendsVC()!
        vc.delegate = self
        let friends = firebase.usersRef.rx_observe(.Value).map { [unowned self] (snapshot: FDataSnapshot) -> [User] in
            var friends = [User]()
            for child in snapshot.children {
                let uid = child.key!!
                let childSnapshot = snapshot.childSnapshotForPath(uid)
                let username = childSnapshot.value["username"] as! String
                let fullName = childSnapshot.value["fullName"] as! String
                let friend = User(uid: uid, username: username, fullName: fullName)
                friends.append(friend)
            }
            return friends.filter {$0.uid != self.firebase.uid}
        }
        vc.inject(FriendsViewModel(friends: friends))
        let navC = UINavigationController(rootViewController: vc)
        navCtrl.viewControllers.last?.presentViewController(navC, animated: false, completion: nil)
    }
}

extension ChatCoordinator: ChatsDelegate {
    func didSelectUser(user: User) {
        pushChatScreen(user)
    }
    
    func didAddChat() {
        pushFriendsScreen()
    }
}

extension ChatCoordinator: FriendsDelegate {
    func friendSelected(friend: User, vc: FriendsVC) {
        pushChatScreen(friend)
        vc.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ChatCoordinator: ChatDelegate {
    func messageAdded(text: String) {
        
    }
}