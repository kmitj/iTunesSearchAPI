//
//  AppDelegate.swift
//  iTunesSearchApi
//
//  Created by km1tj on 22/08/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //mojno ispolzovat coordinatori dlya navigasii.
        let rvc = SearchViewController(viewModel: .init(networkService: NetworkService()))
        let nvc = UINavigationController(rootViewController: rvc)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.tintColor = UIColor.systemGreen
        self.window?.rootViewController = nvc
        self.window?.makeKeyAndVisible()
        return true
    }
}
