//
//  AppDelegate.swift
//  GameOn
//
//  Created by Daniel on 5/14/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var coordinator: AppCoordinator?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let navCtrl = UINavigationController()
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = navCtrl
        window?.makeKeyAndVisible()
        coordinator = AppCoordinator(root: navCtrl, firebase: FirebaseService())
        coordinator?.start()
        return true
    }
}