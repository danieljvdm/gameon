//
//  Chat.swift
//  GameOn
//
//  Created by Daniel on 5/17/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//
import RxSwift
import JSQMessagesViewController

class Chat {
    let chatId: String
    let messages: Variable<[JSQMessage]>
    let typing: Variable<Bool>
    
    init(chatId: String, messages: Variable<[JSQMessage]>, typing: Variable<Bool>){
        self.chatId = chatId
        self.messages = messages
        self.typing = typing
    }
}