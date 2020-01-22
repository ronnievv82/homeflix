//
//  AppDelegate.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 04/09/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = HomeViewController()
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
}

