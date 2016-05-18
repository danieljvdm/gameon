//
//  Coordinator.swift
//  GameOn
//
//  Created by Daniel on 5/14/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import Foundation
import UIKit

protocol CoordinatorType {
    var navCtrl: UINavigationController! {get set}
    var firebase: FirebaseService! {get set}
    init()
    init(root: UINavigationController, firebase: FirebaseService)
    func start()
}

extension CoordinatorType {
    init(root: UINavigationController, firebase: FirebaseService){
        self.init()
        self.navCtrl = root
        self.firebase = firebase
    }
}