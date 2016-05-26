//
//  FriendsVC.swift
//  GameOn
//
//  Created by Daniel on 5/17/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol FriendsDelegate: class {
    func friendSelected(friend: User, vc: FriendsVC)
}

class FriendsVC: UIViewController, Injectable, Reactive {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: FriendsViewModel!
    weak var delegate: FriendsDelegate?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        configureView()
    }
    
    func bindViewModel() {
        viewModel.friends
            .observeOn(MainScheduler.instance)
            .bindTo(tableView.rx_itemsWithCellIdentifier("cell", cellType: FriendCell.self)){  (index, model, cell) in
                cell.nameLabel.text = model.fullName
        }.addDisposableTo(disposeBag)
    }
    
    func configureView() {
        tableView.rx_modelSelected(User.self).subscribeNext { [unowned self] user in
            self.delegate?.friendSelected(user, vc: self)
        }.addDisposableTo(disposeBag)
        
        cancelButton.rx_tap.subscribeNext { [unowned self] in
            self.dismissViewControllerAnimated(true, completion: nil)
        }.addDisposableTo(disposeBag)
    }
    
}
