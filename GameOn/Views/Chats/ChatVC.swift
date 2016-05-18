//
//  ChatVC.swift
//  GameOn
//
//  Created by Daniel on 5/14/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import RxSwift

protocol ChatDelegate: class {
    func messageAdded(text: String)
}

class ChatVC: JSQMessagesViewController, Injectable {
    
    var viewModel: ChatViewModel!
    private var outgoingBubbleImageView: JSQMessagesBubbleImage!
    private var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var messageAdded: ((text: String) -> Void)!
    var typingChanged: ((bool: Bool) -> Void)!
    
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            typingChanged(bool: newValue)
        }
    }
    
    weak var delegate: ChatDelegate?
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupBubbles()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.messages.asObservable().subscribeNext { [unowned self] message in
            self.finishReceivingMessage()
        }.addDisposableTo(disposeBag)
        
        viewModel.typing.asObservable().subscribeNext { [unowned self] bool in
            self.showTypingIndicator = bool
        }.addDisposableTo(disposeBag)
    }
    
    private func configureView(){
        title = viewModel.title
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }
    
    override func viewWillDisappear(animated: Bool) {
        isTyping = false
    }
}

extension ChatVC {
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return viewModel.messages.value[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return viewModel.messages.value.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = viewModel.messages.value[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        if viewModel.messages.value[indexPath.row].senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        messageAdded(text: text)
        isTyping = false
        finishSendingMessage()
    }
}
