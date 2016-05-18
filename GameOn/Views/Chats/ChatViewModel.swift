//
//  ChatViewModel.swift
//  GameOn
//
//  Created by Daniel on 5/16/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Firebase
import RxSwift
import FirebaseRxSwiftExtensions

struct ChatViewModel: ViewModelType {
    private let chat: Chat
    private let user: User
    var messages: Variable<[JSQMessage]>
    var typing: Variable<Bool>
    
    var title: String {
        return user.fullName
    }
    
    init(chat: Chat, user: User){
        self.chat = chat
        self.messages = chat.messages
        self.typing = chat.typing
        self.user = user
    }
}