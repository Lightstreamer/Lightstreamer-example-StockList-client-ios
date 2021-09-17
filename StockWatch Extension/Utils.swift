//
//  Utils.swift
//  StockWatch Extension
//
//  Created by acarioni on 16/09/21.
//  Copyright © 2021 Weswit srl. All rights reserved.
//

import Foundation
import UIKit

let PUSH_SERVER_URL = "https://push.lightstreamer.com"
let ADAPTER_SET = "DEMO"
let DATA_ADAPTER = "QUOTE_ADAPTER"


let NUMBER_OF_ITEMS = 30
let NUMBER_OF_LIST_FIELDS = 4
let NUMBER_OF_DETAIL_FIELDS = 11

let TABLE_ITEMS = ["item1", "item2", "item3", "item4", "item5", "item6", "item7", "item8", "item9", "item10", "item11", "item12", "item13", "item14", "item15", "item16", "item17", "item18", "item19", "item20", "item21", "item22", "item23", "item24", "item25", "item26", "item27", "item28", "item29", "item30"]
let LIST_FIELDS = ["last_price", "time", "pct_change", "stock_name"]
let DETAIL_FIELDS = ["last_price", "time", "pct_change", "bid_quantity", "bid", "ask", "ask_quantity", "min", "max", "open_price", "stock_name"]

let NOTIFICATION_CONN_STATUS = "LSConnectionStatusChanged"
let NOTIFICATION_CONN_ENDED = "LSConnectionEnded"
let NOTIFICATION_MPN_ENABLED = "LSMPNEnabled"
let NOTIFICATION_MPN_UPDATED = "LSMPNSubscriptionCacheUpdated"

let FLASH_DURATION = 0.150

let DARK_GREEN_COLOR = UIColor(red: 0.0000, green: 0.6000, blue: 0.2000, alpha: 1.0)
let RED_COLOR = UIColor(red: 1.0000, green: 0.0706, blue: 0.0000, alpha: 1.0)

let GREEN_COLOR = UIColor(red: 0.5647, green: 0.9294, blue: 0.5373, alpha: 1.0)
let ORANGE_COLOR = UIColor(red: 0.9843, green: 0.7216, blue: 0.4510, alpha: 1.0)
