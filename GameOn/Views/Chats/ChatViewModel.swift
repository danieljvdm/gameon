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
    private let user: User
    var messages: Variable<[JSQMessage]>
    var typing = Variable<Bool>(false)
    var title: String {
        return user.fullName
    }
    
    init(user: User, messages: Variable<[JSQMessage]>){
        self.user = user
        self.messages = messages
    }
}