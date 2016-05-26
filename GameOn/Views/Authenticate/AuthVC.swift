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
import FirebaseAuth
import TwitterKit

protocol AuthDelegate: class {
    func didSelectTwitter(vc: AuthVC)
    func selectedAnonymous(vc: AuthVC)
}

final class AuthVC: UIViewController, Injectable {

    @IBOutlet weak var twitterButton: UIButton!
    var viewModel: AuthViewModel!
    weak var delegate: AuthDelegate?
    var twitterLogin: TWTRLogInCompletion?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assertDependencies()
        configureViews()
    }
    
    private func configureViews() {
        let logInButton = TWTRLogInButton(logInCompletion: twitterLogin!)
        
        // TODO: Change where the log in button is positioned in your view
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
        
        twitterButton.rx_tap
            .subscribeNext { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.selectedAnonymous(strongSelf)
            }.addDisposableTo(disposeBag)
    }
    
    func inject(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

}
