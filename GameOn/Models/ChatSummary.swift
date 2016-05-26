//
//  ChatSummary.swift
//  GameOn
//
//  Created by Daniel on 5/19/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import RxSwift

class ChatSummary {
    let chatId: String
    let user: User
    let lastMessage: Observable<Message>
    
    init(chatId: String, user: User, lastMessage: Observable<Message>) {
        self.chatId = chatId
        self.user = user
        self.lastMessage = lastMessage
    }
}