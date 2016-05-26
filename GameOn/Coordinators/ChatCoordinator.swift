//
//  ChatCoordinator.swift
//  GameOn
//
//  Created by Daniel on 5/14/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import Foundation
import UIKit
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
        let chats = ChatsViewModel(chats: firebase.getActiveChats())
        vc.inject(chats)
        vc.delegate = self
        navCtrl.pushViewController(vc, animated: false)
    }
    
    func pushChatScreen(user: User) {
        firebase.getChat(for: user).subscribeNext { chat in
            var vc = R.storyboard.chats.chatVC()!
            vc.inject(ChatViewModel(chat: chat, user: user))
            vc.messageAdded = { [unowned self] text in
                self.firebase.addMessage(text, to: chat)
            }
            vc.typingChanged = { [unowned self] bool in
                self.firebase.isTyping(bool, in: chat)
            }
            
            vc.senderId = self.firebase.uid
            vc.senderDisplayName = user.fullName ?? ""
            self.navCtrl.pushViewController(vc, animated: true)
        }.addDisposableTo(disposeBag)
    }
    
    func pushFriendsScreen() {
        var vc = R.storyboard.chats.friendsVC()!
        vc.delegate = self
        vc.inject(FriendsViewModel(friends: firebase.getFriends()))
        let navC = UINavigationController(rootViewController: vc)
        navCtrl.viewControllers.last?.presentViewController(navC, animated: true, completion: nil)
    }
}

extension ChatCoordinator: ChatsDelegate {
    func didSelectChat(chat: ChatSummary) {
        pushChatScreen(chat.user)
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