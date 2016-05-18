//
//  AuthVC.swift
//  GameOn
//
//  Created by Daniel on 5/15/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol AuthDelegate: class {
    func didSelectTwitter(vc: AuthVC)
}

final class AuthVC: UIViewController, Injectable {

    @IBOutlet weak var twitterButton: UIButton!
    var viewModel: AuthViewModel!
    weak var delegate: AuthDelegate?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assertDependencies()
        configureViews()
    }
    
    private func configureViews() {
        twitterButton.rx_tap
            .subscribeNext { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.didSelectTwitter(strongSelf)
            }.addDisposableTo(disposeBag)
    }
    
    func inject(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

}
