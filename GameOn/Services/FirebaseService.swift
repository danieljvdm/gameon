//
//  FirebaseService.swift
//  GameOn
//
//  Created by Daniel on 5/15/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import Firebase
import FirebaseRxSwiftExtensions
import RxSwift
import JSQMessagesViewController

class FirebaseService {
    private let baseUrl = "https://game-on-app.firebaseio.com"
    let rootRef: Firebase

    var uid: String {
        return rootRef.authData.uid
    }
    
    var userRef: Firebase {
        return usersRef.childByAppendingPath(uid)
    }
    
    var userChatsRef: Firebase {
        return userRef.childByAppendingPath("chats")
    }
    
    var usersRef: Firebase {
        return rootRef.childByAppendingPath("users")
    }

    var chatsRef: Firebase {
        return rootRef.childByAppendingPath("chats")
    }

    init() {
        rootRef = Firebase(url: baseUrl)
    }
    
    //MARK: - Friends functions
    func getFriends() -> Observable<[User]> {
        return Observable.create { [unowned self] observer in
            self.usersRef.observeSingleEventOfType(.Value) { [unowned self] (snapshot: FDataSnapshot!) in
                var friends = [User]()

                for child in snapshot.children {
                    let uid = child.key!
                    let childSnapshot = snapshot.childSnapshotForPath(uid)
                    let username = childSnapshot.value["username"] as! String
                    let fullName = childSnapshot.value["fullName"] as! String
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
    func getChatWith(user: User) -> Observable<Chat> {
        return Observable.create { [unowned self] observer in
            let ref = self.userChatsRef.childByAppendingPath(user.uid)
            ref.observeSingleEventOfType(.Value) { [unowned self] (snapshot: FDataSnapshot!) in
                var chatRef: Firebase
                if snapshot.value is NSNull {
                    chatRef = self.chatsRef.childByAutoId()
                    chatRef.childByAppendingPath("typingIndicator").setValue([self.uid : false, user.uid : false])
                    ref.setValue(["chatId" : chatRef.key])
                    let ref2 = self.usersRef.childByAppendingPath("\(user.uid)/chats/\(self.uid)")
                    ref2.setValue(["chatId" : chatRef.key])
                } else {
                    chatRef = self.chatsRef.childByAppendingPath(snapshot.value.objectForKey("chatId") as! String)
                }
                
                let messagesRef = chatRef.childByAppendingPath("messages")
                
                let messages = Variable<[JSQMessage]>([])
                messagesRef.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
                    let senderId = snapshot.value["senderId"] as! String
                    let text = snapshot.value["text"] as! String
                    messages.value.append(JSQMessage(senderId: senderId, displayName: "", text: text))
                }
                
                let typingRef = chatRef.childByAppendingPath("typingIndicator")
                
                let typing = Variable(false)
                typingRef.queryOrderedByValue().queryEqualToValue(true).observeEventType(.Value) { (snapshot: FDataSnapshot!) in
                    if snapshot.childrenCount == 1 && snapshot.hasChild(self.uid) {
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
        let messageRef = refForChat(chat).childByAppendingPath("messages").childByAutoId()
        let message = ["senderId" : uid, "text": text]
        messageRef.setValue(message)
        refForChat(chat).updateChildValues(["lastMessageAt" : NSDate().timeIntervalSince1970 * 1000])
    }
    
    func isTyping(bool: Bool, in chat: Chat) {
        let userTypingRef = refForChat(chat).childByAppendingPath("typingIndicator/\(uid)")
        userTypingRef.setValue(bool)
        userTypingRef.onDisconnectRemoveValue()
    }
    
    func refForChat(chat: Chat) -> Firebase {
        return chatsRef.childByAppendingPath(chat.chatId)
    }
    
}