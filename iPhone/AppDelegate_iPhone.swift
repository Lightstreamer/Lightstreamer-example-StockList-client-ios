//  Converted to Swift 5.4 by Swiftify v5.4.24488 - https://swiftify.com/
//
//  AppDelegate_iPhone.swift
//  StockList Demo for iOS
//
// Copyright (c) Lightstreamer Srl
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import LightstreamerClient

//@UIApplicationMain
class AppDelegate_iPhone: NSObject, UIApplicationDelegate, StockListAppDelegate {

    var navController: UINavigationController?


    // MARK: -
    // MARK: Properties
    @IBOutlet var window: UIWindow?
    private(set) var stockListController: StockListViewController?

    // MARK: -
    // MARK: Application lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.statusBarStyle = .lightContent

        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = .darkGray
            navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
        
        // Uncomment for detailed logging
        // LightstreamerClient.setLoggerProvider(ConsoleLoggerProvider(level: .debug))

        // Create the user interface
        stockListController = StockListViewController()

        if let stockListController = stockListController {
            navController = UINavigationController(rootViewController: stockListController)
        }
        navController?.navigationBar.barStyle = .black

        window?.rootViewController = navController
        window?.makeKeyAndVisible()

        return true
    }

    // MARK: -
    // MARK: Properties
}
