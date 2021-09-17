//  Converted to Swift 5.4 by Swiftify v5.4.22271 - https://swiftify.com/
//
//  InterfaceController.swift
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
import Lightstreamer_watchOS_Client

class InterfaceController: WKInterfaceController, LSSubscriptionDelegate {
    private var subscribed = false
    private var subscription: LSSubscription?
    private var selectedItem = 0
    private var itemUpdated: [Int : [String:Bool]]?
    private var itemData: [Int : [String:String?]]?
    let lockQueue = DispatchQueue(label: "com.lightstreamer.InterfaceController")

    // MARK: -
    // MARK: Stock selection
    @IBOutlet var stockPicker: WKInterfacePicker!
    // MARK: -
    // MARK: Data visualization
    @IBOutlet var priceGroup: WKInterfaceGroup!
    @IBOutlet var lastLabel: WKInterfaceLabel!
    @IBOutlet var changeLabel: WKInterfaceLabel!
    @IBOutlet var dirImage: WKInterfaceImage!
    @IBOutlet var openLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!

    // MARK: -
    // MARK: Lightstreamer connection status management

    // MARK: -
    // MARK: Internals

    // MARK: -
    // MARK: Life cycle

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Multiple-item data structures: each item has a second-level dictionary.
        // They store fields data and which fields have been updated
        itemData = [Int : [String:String?]](minimumCapacity: NUMBER_OF_ITEMS)
        itemUpdated = [Int : [String:Bool]](minimumCapacity: NUMBER_OF_ITEMS)

        // We use the notification center to know when the
        // connection changes status
        NotificationCenter.default.addObserver(self, selector: #selector(connectionStatusChanged), name: NSNotification.Name(NOTIFICATION_CONN_STATUS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectionEnded), name: NSNotification.Name(NOTIFICATION_CONN_ENDED), object: nil)

        // Fill the picker
        updatePicker()

        // Start connection (executes in background)
        Connector.shared().connect()
    }

    override func willActivate() {
        super.willActivate()

        // Nothing to do, for now
    }

    override func didDeactivate() {
        super.didDeactivate()

        // Nothing to do, for now
    }

    // MARK: -
    // MARK: Stock selection

    @IBAction func stockSelected(_ value: Int) {
        selectedItem = value

        // Update the view
        updateData()
    }

    // MARK: -
    // MARK: Lighstreamer connection status management

    @objc func connectionStatusChanged() {
        // This method is always called from a background thread

        // Check if we need to subscribe
        let needsSubscription = !subscribed && Connector.shared().isConnected
        if needsSubscription {
            subscribed = true

            print("InterfaceController: subscribing table...")

            // The LSLightstreamerClient will reconnect and resubscribe automatically
            subscription = LSSubscription(subscriptionMode: "MERGE", items: TABLE_ITEMS, fields: DETAIL_FIELDS)
            subscription?.dataAdapter = DATA_ADAPTER
            subscription?.requestedSnapshot = "yes"
            subscription?.addDelegate(self)

            Connector.shared().subscribe(subscription)
        }
    }

    @objc func connectionEnded() {
        // This method is always called from a background thread

        // Connection was forcibly closed by the server,
        // prepare for a new subscription
        subscribed = false
        subscription = nil

        // Start a new connection (executes in background)
        Connector.shared().connect()
    }

    // MARK: -
    // MARK: Methods of LSSubscriptionDelegate

    func subscription(_ subscription: LSSubscription, didUpdateItem itemUpdate: LSItemUpdate) {
        // This method is always called from a background thread

        let itemPosition = Int(itemUpdate.itemPos)
        var updatePicker = false

        // Check and prepare the item's data structures
        var item: [String : String?]? = nil
        var itemUpdated: [String : Bool]? = nil
        lockQueue.sync {
            item = itemData?[itemPosition - 1]
            if item == nil {
                item = [String : String?](minimumCapacity: NUMBER_OF_DETAIL_FIELDS)
                itemData?[itemPosition - 1] = item
            }

            itemUpdated = self.itemUpdated?[itemPosition - 1]
            if itemUpdated == nil {
                itemUpdated = [String : Bool](minimumCapacity: NUMBER_OF_DETAIL_FIELDS)
                self.itemUpdated?[itemPosition - 1] = itemUpdated
            }
        }

        var previousLastPrice = 0.0
        for fieldName in DETAIL_FIELDS {

            // Save previous last price to choose blink color later
            if fieldName == "last_price" {
                previousLastPrice = Double((item?[fieldName] ?? "0") ?? "0") ?? 0.0
            }

            // Store the updated field in the item's data structures
            let value = itemUpdate.value(withFieldName: fieldName)

            if value != "" {
                item?[fieldName] = value
            } else {
                item?[fieldName] = nil
            }

            if itemUpdate.isValueChanged(withFieldName: fieldName) {
                itemUpdated?[fieldName] = true

                // If the stock name changed we also have to reload the picker
                if fieldName == "stock_name" {
                    updatePicker = true
                }
            }
        }

        // Evaluate the update color and store it in the item's data structures
        let currentLastPrice = Double(itemUpdate.value(withFieldName: "last_price") ?? "0") ?? 0
        if currentLastPrice >= previousLastPrice {
            item?["color"] = "green"
        } else {
            item?["color"] = "orange"
        }
        
        lockQueue.sync {
            self.itemData?[itemPosition - 1] = item
            self.itemUpdated?[itemPosition - 1] = itemUpdated
        }

        let updateData = selectedItem == (itemPosition - 1)
        if updateData {
            DispatchQueue.main.async(execute: { [self] in

                // Update the view
                self.updateData()
            })
        }

        if updatePicker {
            DispatchQueue.main.async(execute: { [self] in

                // Update the picker
                self.updatePicker()
            })
        }
    }

    // MARK: -
    // MARK: Internals

    func updatePicker() {
        // This method is always called from the main thread

        var pickerItems: [AnyHashable] = []

        lockQueue.sync {
            for i in 0..<NUMBER_OF_ITEMS {
                let item = itemData?[i]
                let stockName = item?["stock_name"]

                let pickerItem = WKPickerItem()
                pickerItem.title = stockName ?? "Loading item\(i + 1)..."
                pickerItems.append(pickerItem)
            }
        }

        stockPicker.setItems(pickerItems as? [WKPickerItem])
    }

    func updateData() {
        // This method is always called from the main thread

        // Retrieve the item's data structures
        var item: [String : String?]? = nil
        var itemUpdated: [String : Bool]? = nil
        lockQueue.sync {
            item = itemData?[selectedItem]
            itemUpdated = self.itemUpdated?[selectedItem]
        }

        if let item = item {

            // Update the labels
            lastLabel.setText(item["last_price"] ?? "")
            if itemUpdated?["last_price"] ?? false {

                // Flash the price-dir-change group appropriately
                let colorName = item["color"] as? String
                var color: UIColor? = nil
                if colorName == "green" {
                    color = GREEN_COLOR
                } else if colorName == "orange" {
                    color = ORANGE_COLOR
                } else {
                    color = UIColor.white
                }

                WatchSpecialEffects.flash(priceGroup, with: color)

                itemUpdated?["last_price"] = false
            }

            timeLabel.setText(item["time"] ?? "")
            openLabel.setText(item["open_price"] ?? "")

            let pctChange = Double((item["pct_change"] ?? "0") ?? "0") ?? 0.0
            if pctChange > 0.0 {
                dirImage.setImage(UIImage(named: "Arrow-up"))
            } else if pctChange < 0.0 {
                dirImage.setImage(UIImage(named: "Arrow-down"))
            } else {
                dirImage.setImage(nil)
            }

            if let object = item["pct_change"] ?? "0" {
                changeLabel.setText(String(format: "%@%%", object))
            }
            changeLabel.setTextColor((Double((item["pct_change"] ?? "0") ?? "0") ?? 0.0 >= 0.0) ? DARK_GREEN_COLOR : RED_COLOR)
            
            lockQueue.sync {
                self.itemData?[selectedItem] = item
                self.itemUpdated?[selectedItem] = itemUpdated
            }
        }
    }
}

// MARK: -
// MARK: InterfaceController extension
// MARK: -
// MARK: InterfaceController implementation
