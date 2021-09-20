//  Converted to Swift 5.4 by Swiftify v5.4.22271 - https://swiftify.com/
//
//  WatchSpecialEffects.swift
//  StockWatch Extension
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

import Foundation
import WatchKit

class WatchSpecialEffects: NSObject {
    // MARK: -
    // MARK: UI element flashing
    @objc class func flash(_ group: WKInterfaceGroup?, with color: UIColor?) {
        group?.setBackgroundColor(color)

        WatchSpecialEffects.self.perform(#selector(unflashGrup(_:)), with: group, afterDelay: FLASH_DURATION)
    }

    // MARK: -
    // MARK: Internals

    @objc class func unflashGrup(_ group: WKInterfaceGroup?) {
        group?.setBackgroundColor(UIColor.clear)
    }
}
