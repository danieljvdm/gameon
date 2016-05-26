//
//  UserDetailsVC.swift
//  GameOn
//
//  Created by Daniel on 5/19/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ChameleonFramework

protocol UserDetailsDelegate: class {
    func didRegister(details: (username:String, fullname:String), vc: UserDetailsVC)
}

class UserDetailsVC: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var fullnameField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    weak var delegate: UserDetailsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "User Details"
        doReactiveStuff()
        configureView()
    }
    
    func configureView() {
        
    }
    
    func doReactiveStuff() {
        let usernameValid = usernameField.rx_text.map { $0.characters.count > 5 && !$0.characters.contains(" ")}.shareReplay(1)
        let fullnameValid = fullnameField.rx_text.map { $0.characters.count > 5 }.shareReplay(1)
        
        let everythingValid = Observable.combineLatest(usernameValid, fullnameValid) { $0 && $1 }.shareReplay(1)
        
        usernameValid.bindTo(fullnameField.rx_enabled).addDisposableTo(disposeBag)
        everythingValid.bindTo(registerButton.rx_enabled).addDisposableTo(disposeBag)
        
        usernameValid.subscribeNext { [unowned self] bool in
            if bool {
                self.fullnameField.layer.borderColor = UIColor.blackColor().CGColor
                self.fullnameField.layer.borderWidth = 0.0
            } else {
                self.fullnameField.layer.cornerRadius = 5.0
                self.fullnameField.layer.borderWidth = 2.0
                self.fullnameField.layer.borderColor = UIColor.redColor().CGColor
            }
        }.addDisposableTo(disposeBag)
        
        everythingValid.subscribeNext { [unowned self] bool in
            if bool {
                self.registerButton.backgroundColor = FlatSkyBlue()
            } else {
                self.registerButton.backgroundColor = FlatGray()
            }
        }.addDisposableTo(disposeBag)
        
        registerButton.rx_tap.subscribeNext { [unowned self] in
            self.delegate?.didRegister((self.usernameField.text!, self.fullnameField.text!), vc:self)
        }.addDisposableTo(disposeBag)
    }
    
}