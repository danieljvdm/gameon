//
//  FriendsVC.swift
//  GameOn
//
//  Created by Daniel on 5/14/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ChatsDelegate: class {
    func didSelectChat(_: ChatSummary)
    func didAddChat()
}

class ChatsVC: UIViewController, Injectable, Reactive {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    var viewModel: ChatsViewModel!
    weak var delegate: ChatsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        bindViewModel()
        configureView()
    }
    
    func bindViewModel() {
        viewModel.chats
            .asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier("cell", cellType: ChatsCell.self)) { [unowned self](index, model, cell) in
                cell.nameLabel.text = model.user.fullName
                model.lastMessage.map {$0.text}.bindTo(cell.lastMessageLabel.rx_text).addDisposableTo(self.disposeBag)
        }.addDisposableTo(disposeBag)
    }
    
    func configureView() {
        tableView.rx_modelSelected(ChatSummary.self).subscribeNext { [weak self] chat in
            self?.delegate?.didSelectChat(chat)
        }.addDisposableTo(disposeBag)
        
        addButton.rx_tap.subscribeNext { [unowned self] in
            self.delegate?.didAddChat()
        }.addDisposableTo(disposeBag)
    }
}

extension ChatsVC: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }
}