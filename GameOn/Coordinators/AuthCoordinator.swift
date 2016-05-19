//
//  AuthCoordinator.swift
//  GameOn
//
//  Created by Daniel on 5/16/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import UIKit
import Accounts
import Firebase

protocol AuthCoordinatorDelegate: class {
    func didAuthenticate(coordinator: AuthCoordinator)
}

final class AuthCoordinator: CoordinatorType {
    var navCtrl: UINavigationController!
    var firebase: FirebaseService!
    
    weak var delegate: AuthCoordinatorDelegate?
    
    func start() {
        let vc = R.storyboard.authentication.authVC()!
        vc.delegate = self
        vc.twitterLogin = { session, error in
            if let session = session {
                let credential = FIRTwitterAuthProvider.credentialWithToken(session.authToken, secret: session.authTokenSecret)
                FIRAuth.auth()?.signInWithCredential(credential) { [unowned self] user, error in
                    if let error = error {
                        print(error.userInfo["NSUnderlyingError"])
                    }
                    if user != nil {
                        self.navCtrl.popViewControllerAnimated(true)
                        self.delegate?.didAuthenticate(self)
                    }
                }
            }
        }
        vc.inject(AuthViewModel())
        navCtrl.pushViewController(vc, animated: false)
    }
}

extension AuthCoordinator: AuthDelegate {
    func didSelectTwitter(vc: AuthVC) {
//        let twitter = TwitterAuthHelper(firebaseRef: firebase.rootRef, twitterAppId: "PO1qxaaI9djPdaP8euTMNkvC8")
//        twitter.selectTwitterAccountWithCallback { [weak self] error, accounts in
//            if error != nil {
//
//            } else if accounts.count == 1 {
//                guard let account = accounts.first as? ACAccount else { return }
//                self?.authenticate(twitter, account: account)
//            } else if accounts.count > 1 {
//                let actionSheet = UIAlertController(title: "Select Twitter Account", message: nil, preferredStyle: .ActionSheet)
//                for case let account as ACAccount in accounts {
//                    let action = UIAlertAction(title: account.username, style: .Default, handler: { action in
//                        self?.authenticate(twitter, account: account)
//                    })
//                    actionSheet.addAction(action)
//                }
//                vc.presentViewController(actionSheet, animated: true, completion: nil)
//            }
//        }

    }
    
//    func authenticate(helper: TwitterAuthHelper, account: ACAccount) {
//        helper.authenticateAccount(account) { [weak self] error, authData in
//            guard let strongSelf = self else { return }
//            if error != nil {
//                
//            } else {
//                self?.firebase.usersRef.childByAppendingPath(authData.uid).updateChildValues(["username" : account.username, "fullName" : account.userFullName])
//                strongSelf.navCtrl.popViewControllerAnimated(false)
//                strongSelf.delegate?.didAuthenticate(strongSelf)
//            }
//        }
//
//    }
}