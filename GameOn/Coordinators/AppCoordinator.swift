//
//  AppCoordinator.swift
//  GameOn
//
//  Created by Daniel on 5/14/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Firebase

final class AppCoordinator: CoordinatorType {
    var navCtrl: UINavigationController!
    var firebase: FirebaseService!
    private let disposeBag = DisposeBag()
    var coordinators = [CoordinatorType]()
    
    func start() {
        try! FIRAuth.auth()?.signOut()
        if FIRAuth.auth()?.currentUser == nil {
            presentAuth()
        } else {
            presentChat()
        }
    }
    
    func presentAuth() {
        let coordinator = AuthCoordinator(root: navCtrl, firebase: firebase)
        coordinator.delegate = self
        coordinators.append(coordinator)
        coordinator.start()
    }
    
    func presentChat() {
        let coordinator = ChatCoordinator(root: navCtrl, firebase: firebase)
        coordinator.delegate = self
        coordinators.append(coordinator)
        coordinator.start()
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func didAuthenticate(coordinator: AuthCoordinator) {
        coordinators.popLast()
        presentChat()
    }
}

extension AppCoordinator: ChatCoordinatorDelegate {
    
}