//
//  FriendsViewModel.swift
//  GameOn
//
//  Created by Daniel on 5/16/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//
import Firebase
import RxSwift

class ChatsViewModel: ViewModelType {
    let chats: Observable<[ChatSummary]>
    
    init(chats: Observable<[ChatSummary]>){
        self.chats = chats
    }
}