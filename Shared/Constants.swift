//  Converted to Swift 5.4 by Swiftify v5.4.24488 - https://swiftify.com/
/*
 *  Constants.swift
 *  StockList Demo for iOS
 *
 * Copyright (c) Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit

// Configuration for local installation
let PUSH_SERVER_URL = "http://localhost:8080/"
let ADAPTER_SET = "STOCKLISTDEMO"
let DATA_ADAPTER = "STOCKLIST_ADAPTER"

// Configuration for online demo server
//let PUSH_SERVER_URL = "https://push.lightstreamer.com"
//let ADAPTER_SET = "DEMO"
//let DATA_ADAPTER = "QUOTE_ADAPTER"


#if os(iOS)
let DEVICE_IPAD = UIDevice.current.userInterfaceIdiom == .pad

func DEVICE_XIB(_ xib: String) -> String {
    DEVICE_IPAD ? xib + "_iPad" : xib + "_iPhone"
}
#endif

let NUMBER_OF_ITEMS = 30
let NUMBER_OF_LIST_FIELDS = 4
let NUMBER_OF_DETAIL_FIELDS = 11

let TABLE_ITEMS = ["item1", "item2", "item3", "item4", "item5", "item6", "item7", "item8", "item9", "item10", "item11", "item12", "item13", "item14", "item15", "item16", "item17", "item18", "item19", "item20", "item21", "item22", "item23", "item24", "item25", "item26", "item27", "item28", "item29", "item30"]

let LIST_FIELDS = ["last_price", "time", "pct_change", "stock_name"]

let DETAIL_FIELDS = ["last_price", "time", "pct_change", "bid_quantity", "bid", "ask", "ask_quantity", "min", "max", "open_price", "stock_name"]

let NOTIFICATION_CONN_STATUS = NSNotification.Name("LSConnectionStatusChanged")
let NOTIFICATION_CONN_ENDED = NSNotification.Name("LSConnectionEnded")
let NOTIFICATION_MPN_ENABLED = NSNotification.Name("LSMPNEnabled")
let NOTIFICATION_MPN_UPDATED = NSNotification.Name("LSMPNSubscriptionCacheUpdated")

let ALERT_DELAY = 0.250
let FLASH_DURATION = 0.150

let GREEN_COLOR = UIColor(red: 0.5647, green: 0.9294, blue: 0.5373, alpha: 1.0)
let ORANGE_COLOR = UIColor(red: 0.9843, green: 0.7216, blue: 0.4510, alpha: 1.0)

let DARK_GREEN_COLOR = UIColor(red: 0.0000, green: 0.6000, blue: 0.2000, alpha: 1.0)
let RED_COLOR = UIColor(red: 1.0000, green: 0.0706, blue: 0.0000, alpha: 1.0)

let LIGHT_ROW_COLOR = UIColor(red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0)
let DARK_ROW_COLOR = UIColor(red: 0.8667, green: 0.8667, blue: 0.9373, alpha: 1.0)
let SELECTED_ROW_COLOR = UIColor(red: 0.0000, green: 0.0000, blue: 1.0000, alpha: 1.0)

let DEFAULT_TEXT_COLOR = UIColor(red: 0.0000, green: 0.0000, blue: 0.0000, alpha: 1.0)
let SELECTED_TEXT_COLOR = UIColor(red: 1.0000, green: 1.0000, blue: 1.0000, alpha: 1.0)

let COLORED_LABEL_TAG = 456

let FLIP_DURATION = 0.3

let INFO_IPAD_WIDTH = 600.0
let INFO_IPAD_HEIGHT = 400.0

let STATUS_IPAD_WIDTH = 400.0
let STATUS_IPAD_HEIGHT = 230.0
