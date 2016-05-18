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
    func didSelectUser(_: User)
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
        bindViewModel()
        configureView()
    }
    
    func bindViewModel() {
        viewModel.friends
            .asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier("cell", cellType: ChatsCell.self)) { (index, model, cell) in
                cell.nameLabel.text = model.fullName
                cell.lastMessageLabel.text = model.username
        }.addDisposableTo(disposeBag)
    }
    
    func configureView() {
        tableView.rx_modelSelected(User.self).subscribeNext { [weak self] user in
            self?.delegate?.didSelectUser(user)
        }.addDisposableTo(disposeBag)
        
        addButton.rx_tap.subscribeNext { [unowned self] in
            self.delegate?.didAddChat()
        }.addDisposableTo(disposeBag)
    }
}