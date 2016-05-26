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
    
    func isLoggedIn() -> Observable<Bool> {
        return Observable.create { observer in
            FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
                if user != nil {
                    observer.onNext(true)
                } else {
                    observer.onNext(false)
                }
            }
            return AnonymousDisposable {}
        }
    }
    
    func authenticate(credential: FIRAuthCredential) -> Observable<FIRUser?> {
        return Observable.create { observer in
            FIRAuth.auth()?.signInWithCredential(credential) { user, error in
                observer.onNext(user)
                observer.onCompleted()
            }
            return AnonymousDisposable {}
        }
    }
    
    //MARK: - Friends functions
    func getFriends() -> Observable<[User]> {
        return Observable.create { [unowned self] observer in
            self.usersRef.observeSingleEventOfType(.Value) { [unowned self] (snapshot: FIRDataSnapshot) in
                var friends = [User]()
                for case let child as FIRDataSnapshot in snapshot.children {
                    let uid = child.key
                    let username = child.value!["username"] as! String
                    let fullName = child.value!["fullName"] as! String
                    let friend = User(uid: uid, username: username, fullName: fullName)
                    friends.append(friend)
                }
                observer.onNext(friends.filter { $0.uid != self.uid } )
                observer.onCompleted()
            }
            
            return AnonymousDisposable {
            
            }
        }
    }

    //MARK: - Chat functions
    func getActiveChats() -> Observable<[ChatSummary]> {
        let chats = Variable<[ChatSummary]>([])
        self.userChatsRef.observeEventType(.ChildAdded) { [unowned self] (chatSnapshot: FIRDataSnapshot) in
            let chatUserRef = self.usersRef.child(chatSnapshot.key)
            let chatId = chatSnapshot.value!["chatId"] as! String
            let chatRef = self.chatsRef.child("\(chatId)/messages")
            let lastMessage = Variable<Message>(Message(senderId: "", text: ""))
            chatUserRef.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
                let uid = snapshot.key
                let username = snapshot.value!["username"] as! String
                let fullName = snapshot.value!["fullName"] as! String
                let user = User(uid: uid, username: username, fullName: fullName)                
                chatRef.queryLimitedToLast(1).observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
                    guard let childSnapshot = snapshot.children.allObjects.first as? FIRDataSnapshot else { return }
                    let messageText = childSnapshot.value!["text"] as! String
                    let senderId = childSnapshot.value!["senderId"] as! String
                    lastMessage.value = Message(senderId: senderId, text: messageText)
                }
                let chat = ChatSummary(chatId: chatId, user: user, lastMessage: lastMessage.asObservable())
                chats.value.append(chat)    
            }
           
        }
        return chats.asObservable()
    }
    
    func getChat(for user: User) -> Observable<Chat> {
        return Observable.create { [unowned self] observer in
            let ref = self.userChatsRef.child(user.uid)
            ref.observeSingleEventOfType(.Value) { [unowned self] (snapshot: FIRDataSnapshot) in
                var chatRef: FIRDatabaseReference
                
                //Check if a chat with this user already exists
                if let value = snapshot.value as? NSDictionary {
                    chatRef = self.chatsRef.child(value["chatId"] as! String)
                } else {
                    chatRef = self.chatsRef.childByAutoId()
                    ref.setValue(["chatId" : chatRef.key])
                    let ref2 = self.usersRef.child("\(user.uid)/chats/\(self.uid!)")
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
        refForChat(chat).updateChildValues(FIRServerValue.timestamp())
    }
    
    func isTyping(bool: Bool, in chat: Chat) {
        let userTypingRef = refForChat(chat).child("typingIndicator/\(uid!)")
        userTypingRef.setValue(bool)
        userTypingRef.onDisconnectRemoveValue()
    }
    
    func refForChat(chat: Chat) -> FIRDatabaseReference {
        return chatsRef.child(chat.chatId)
    }
    
}