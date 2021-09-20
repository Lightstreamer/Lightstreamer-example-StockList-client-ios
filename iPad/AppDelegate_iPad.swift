//  Converted to Swift 5.4 by Swiftify v5.4.24488 - https://swiftify.com/
//
//  AppDelegate_iPad.swift
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
class AppDelegate_iPad: NSObject, UIApplicationDelegate, StockListAppDelegate {

    var splitController: UISplitViewController?



    // MARK: -
    // MARK: Properties
    @IBOutlet var window: UIWindow?
    private(set) var stockListController: StockListViewController?
    private(set) var detailController: DetailViewController?

    // MARK: -
    // MARK: Application lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.statusBarStyle = .lightContent

        // Uncomment for detailed logging
        // LightstreamerClient.setLoggerProvider(ConsoleLoggerProvider(level: .debug))

        // Create the user interface
        stockListController = StockListViewController()

        var navController1: UINavigationController? = nil
        if let stockListController = stockListController {
            navController1 = UINavigationController(rootViewController: stockListController)
        }
        navController1?.navigationBar.barStyle = .black

        detailController = DetailViewController()

        var navController2: UINavigationController? = nil
        if let detailController = detailController {
            navController2 = UINavigationController(rootViewController: detailController)
        }
        navController2?.navigationBar.barStyle = .black

        splitController = UISplitViewController()
        splitController?.viewControllers = [navController1, navController2].compactMap { $0 }

        window?.rootViewController = splitController
        window?.makeKeyAndVisible()

        return true
    }

    // MARK: -
    // MARK: Properties
}
