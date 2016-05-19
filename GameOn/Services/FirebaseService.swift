//
//  FirebaseService.swift
//  GameOn
//
//  Created by Daniel on 5/15/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import Firebase
import RxSwift
import JSQMessagesViewController

class FirebaseService {
    let rootRef = FIRDatabase.database().reference()

    var uid: String? {
        return FIRAuth.auth()?.currentUser?.uid
    }
    
    var userRef: FIRDatabaseReference {
        return usersRef.child(uid!)
    }
    
    var userChatsRef: FIRDatabaseReference {
        return userRef.child("chats")
    }
    
    var usersRef: FIRDatabaseReference {
        return rootRef.child("users")
    }

    var chatsRef: FIRDatabaseReference {
        return rootRef.child("chats")
    }
    
    //MARK: - Friends functions
    func getFriends() -> Observable<[User]> {
        return Observable.create { [unowned self] observer in
            self.usersRef.observeSingleEventOfType(.Value) { [unowned self] (snapshot: FIRDataSnapshot) in
                var friends = [User]()
                for case let child as FIRDataSnapshot in snapshot.children {
                    let uid = child.key
                    let username = child.valueForKey("username") as! String
                    let fullName = child.valueForKey("fullName") as! String
                    let friend = User(uid: uid, username: username, fullName: fullName)
                    friends.append(friend)
                }
                
                observer.onNext(friends.filter { $0.uid != self.uid } )
                observer.onCompleted()
            }
            
            return AnonymousDisposable {}
        }
    }

    //MARK: - Chat functions
//    func getChats(for user: User) -> Observable<[Chat]> {
//    
//    }
    
    func getChatWith(user: User) -> Observable<Chat> {
        return Observable.create { [unowned self] observer in
            let ref = self.userChatsRef.child(user.uid)
            ref.observeSingleEventOfType(.Value) { [unowned self] (snapshot: FIRDataSnapshot) in
                var chatRef: FIRDatabaseReference
                if let value = snapshot.value as? NSDictionary {
                    chatRef = self.chatsRef.child(value["chatId"] as! String)
                } else {
                    chatRef = self.chatsRef.childByAutoId()
                    chatRef.child("typingIndicator").setValue([self.uid! : false, user.uid : false])
                    ref.setValue(["chatId" : chatRef.key])
                    let ref2 = self.usersRef.child("\(user.uid)/chats/\(self.uid)")
                    ref2.setValue(["chatId" : chatRef.key])
                }
                
                let messagesRef = chatRef.child("messages")
                
                let messages = Variable<[JSQMessage]>([])
                messagesRef.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
                    guard let value = snapshot.value as? NSDictionary else {return}
                    let senderId = value["senderId"] as! String
                    let text = value["text"] as! String
                    messages.value.append(JSQMessage(senderId: senderId, displayName: "", text: text))
                }
                
                let typingRef = chatRef.child("typingIndicator")
                
                let typing = Variable(false)
                typingRef.queryOrderedByValue().queryEqualToValue(true).observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
                    if snapshot.childrenCount == 1 && snapshot.hasChild(self.uid!) {
                        return
                    }
                    
                    typing.value = snapshot.childrenCount > 0
                }
                
                let chat = Chat(chatId: chatRef.key, messages: messages, typing: typing)
                observer.onNext(chat)
                observer.onCompleted()
            }
            return AnonymousDisposable {}
        }
    }
    
    func addMessage(text: String, to chat: Chat) {
        let messageRef = refForChat(chat).child("messages").childByAutoId()
        let message = ["senderId" : uid!, "text": text]
        messageRef.setValue(message)
        refForChat(chat).updateChildValues(["lastMessageAt" : NSDate().timeIntervalSince1970 * 1000])
    }
    
    func isTyping(bool: Bool, in chat: Chat) {
        let userTypingRef = refForChat(chat).child("typingIndicator/\(uid)")
        userTypingRef.setValue(bool)
        userTypingRef.onDisconnectRemoveValue()
    }
    
    func refForChat(chat: Chat) -> FIRDatabaseReference {
        return chatsRef.child(chat.chatId)
    }
    
}