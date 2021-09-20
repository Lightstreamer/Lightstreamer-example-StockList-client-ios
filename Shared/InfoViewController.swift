//  Converted to Swift 5.4 by Swiftify v5.4.24488 - https://swiftify.com/
//
//  InfoViewController.swift
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

class InfoViewController: UIViewController {
    var infoView: InfoView?

    // MARK: -
    // MARK: Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "Info"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        title = "Info"
    }

    // MARK: -
    // MARK: User actions
    @IBAction func linkTapped() {
        if let url = URL(string: "http://www.lightstreamer.com/") {
            UIApplication.shared.openURL(url)
        }
    }

    // MARK: -
    // MARK: Methods of UIViewController

    override func loadView() {
        let niblets = Bundle.main.loadNibNamed(DEVICE_XIB("InfoView"), owner: self, options: nil)
        infoView = niblets?.last as? InfoView

        view = infoView
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
