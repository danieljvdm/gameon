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
    private let disposeBag = DisposeBag()
    
    func start() {
        presentChatsScreen()
    }
    
    func presentChatsScreen() {
        var vc = R.storyboard.chats.chatsVC()!
        firebase.userChatsRef
        vc.inject(ChatsViewModel())
        vc.delegate = self
        navCtrl.pushViewController(vc, animated: false)
    }
    
    func pushChatScreen(user: User) {
        firebase.getChatWith(user).subscribeNext { chat in
            var vc = R.storyboard.chats.chatVC()!
            vc.inject(ChatViewModel(chat: chat, user: user))
            vc.messageAdded = { [unowned self] text in
                self.firebase.addMessage(text, to: chat)
            }
            vc.typingChanged = { [unowned self] bool in
                self.firebase.isTyping(bool, in: chat)
            }
            
            vc.senderId = self.firebase.uid
            vc.senderDisplayName = user.fullName
            self.navCtrl.pushViewController(vc, animated: false)
        }.addDisposableTo(disposeBag)
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