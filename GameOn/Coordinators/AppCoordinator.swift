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

    var coordinators = [CoordinatorType]()
    
    func start() {
        if firebase.uid != nil {
            presentChat()
        } else {
            presentAuth()
        }
    }
    
    func presentAuth() {
        let coordinator = AuthCoordinator(root: navCtrl, firebase: firebase)
        coordinator.delegate = self
        coordinator.start()
        coordinators.append(coordinator)
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