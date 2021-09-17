//  Converted to Swift 5.4 by Swiftify v5.4.24488 - https://swiftify.com/
//
//  DetailViewController.swift
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

class DetailViewController: UIViewController, SubscriptionDelegate {
    
    let lockQueue = DispatchQueue(label: "lightstreamer.DetailViewController")
    var detailView: DetailView?
    var chartController: ChartViewController?
    var priceMpnSubscription: MPNSubscription?
    var subscription: Subscription?

    var itemData: [String : String]?
    var itemUpdated: [AnyHashable : Any]?

    // MARK: -
    // MARK: Properties
    private(set) var item: String?

    // MARK: -
    // MARK: Notifications from notification center

    // MARK: -
    // MARK: Internals

    // MARK: -
    // MARK: Initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Single-item data structures: they store fields data and
        // which fields have been updated
        itemData = [:]
        itemUpdated = [:]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Single-item data structures: they store fields data and
        // which fields have been updated
        itemData = [:]
        itemUpdated = [:]
    }

    // MARK: -
    // MARK: Methods of UIViewController

    override func loadView() {
        let niblets = Bundle.main.loadNibNamed(DEVICE_XIB("DetailView"), owner: self, options: nil)
        detailView = niblets?.last as? DetailView

        view = detailView

        // Add chart
        chartController = ChartViewController()
        chartController?.view.backgroundColor = UIColor.white
        chartController?.view.frame = CGRect(x: 0.0, y: 0.0, width: detailView?.chartBackgroundView?.frame.size.width ?? 0.0, height: detailView?.chartBackgroundView?.frame.size.height ?? 0.0)

        if let view = chartController?.view {
            detailView?.chartBackgroundView?.addSubview(view)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Reset size of chart
        chartController?.view.frame = CGRect(x: 0.0, y: 0.0, width: detailView?.chartBackgroundView?.frame.size.width ?? 0.0, height: detailView?.chartBackgroundView?.frame.size.height ?? 0.0)
    }

    override func viewDidDisappear(_ animated: Bool) {

        // Unsubscribe the table
        if subscription != nil {
            print("DetailViewController: unsubscribing previous table...")

            Connector.shared().unsubscribe(subscription!)

            subscription = nil
        }
        
        super.viewDidDisappear(animated)
    }

    // MARK: -
    // MARK: Communication with StockList View Controller
    @objc func changeItem(_ item: String?) {
        // This method is always called from the main thread

        // Set current item and clear the data
        lockQueue.sync {
            self.item = item

            itemData?.removeAll()
            itemUpdated?.removeAll()
        }

        // Update the view
        updateView()

        // Reset the chart
        chartController?.clearChart()

        // If needed, unsubscribe previous table
        if subscription != nil {
            print("DetailViewController: unsubscribing previous table...")

            Connector.shared().unsubscribe(subscription!)
            subscription = nil
        }

        // Subscribe new single-item table
        if let item = item {
            print("DetailViewController: subscribing table...")

            // The LSLightstreamerClient will reconnect and resubscribe automatically
            subscription = Subscription(subscriptionMode: .MERGE, items: [item], fields: DETAIL_FIELDS)
            subscription?.dataAdapter = DATA_ADAPTER
            subscription?.requestedSnapshot = .yes
            subscription?.addDelegate(self)

            Connector.shared().subscribe(subscription!)
        }
    }

    // MARK: -
    // MARK: Methods of SubscriptionDelegate
    
    func subscription(_ subscription: Subscription, didClearSnapshotForItemName itemName: String?, itemPos: UInt) {}
    func subscription(_ subscription: Subscription, didLoseUpdates lostUpdates: UInt, forCommandSecondLevelItemWithKey key: String) {}
    func subscription(_ subscription: Subscription, didFailWithErrorCode code: Int, message: String?, forCommandSecondLevelItemWithKey key: String) {}
    func subscription(_ subscription: Subscription, didEndSnapshotForItemName itemName: String?, itemPos: UInt) {}
    func subscription(_ subscription: Subscription, didLoseUpdates lostUpdates: UInt, forItemName itemName: String?, itemPos: UInt) {}
    func subscriptionDidRemoveDelegate(_ subscription: Subscription) {}
    func subscriptionDidAddDelegate(_ subscription: Subscription) {}
    func subscriptionDidSubscribe(_ subscription: Subscription) {}
    func subscription(_ subscription: Subscription, didFailWithErrorCode code: Int, message: String?) {}
    func subscriptionDidUnsubscribe(_ subscription: Subscription) {}
    func subscription(_ subscription: Subscription, didReceiveRealFrequency frequency: RealMaxFrequency?) {}

    func subscription(_ subscription: Subscription, didUpdateItem itemUpdate: ItemUpdate) {
        // This method is always called from a background thread

        let itemName = itemUpdate.itemName

        lockQueue.sync {

            // Check if it is a late update of the previous table
            if item != itemName {
                return
            }

            var previousLastPrice = 0.0
            for fieldName in DETAIL_FIELDS {

                // Save previous last price to choose blick color later
                if fieldName == "last_price" {
                    previousLastPrice = toDouble(itemData?[fieldName])
                }

                // Store the updated field in the item's data structures
                let value = itemUpdate.value(withFieldName: fieldName)

                if value != "" {
                    itemData?[fieldName] = value
                } else {
                    itemData?[fieldName] = nil
                }

                if itemUpdate.isValueChanged(withFieldName: fieldName) {
                    itemUpdated?[fieldName] = NSNumber(value: true)
                }
            }

            let currentLastPrice = Double(itemUpdate.value(withFieldName: "last_price") ?? "0")!
            if currentLastPrice >= previousLastPrice {
                itemData?["color"] = "green"
            } else {
                itemData?["color"] = "orange"
            }
        }

        DispatchQueue.main.async(execute: { [self] in

            // Forward the update to the chart
            chartController?.itemDidUpdate(itemUpdate)

            // Update the view
            updateView()
        })
    }

    // MARK: -
    // MARK: Properties

    // MARK: -
    // MARK: Internals

    func updateView() {
        // This method is always called on the main thread

        lockQueue.sync {

            // Take current item status from item's data structures
            // and update the view appropriately
            let colorName = itemData?["color"]
            var color: UIColor? = nil
            if colorName == "green" {
                color = GREEN_COLOR
            } else if colorName == "orange" {
                color = ORANGE_COLOR
            } else {
                color = UIColor.white
            }

            title = itemData?["stock_name"]

            detailView?.lastLabel?.text = itemData?["last_price"]
            if (itemUpdated?["last_price"] as? NSNumber)?.boolValue ?? false {
                SpecialEffects.flash(detailView?.lastLabel, with: color)
                itemUpdated?["last_price"] = NSNumber(value: false)
            }

            detailView?.timeLabel?.text = itemData?["time"]
            if (itemUpdated?["time"] as? NSNumber)?.boolValue ?? false {
                SpecialEffects.flash(detailView?.timeLabel, with: color)
                itemUpdated?["time"] = NSNumber(value: false)
            }

            let pctChange = toDouble(itemData?["pct_change"])
            if pctChange > 0.0 {
                detailView?.dirImage?.image = UIImage(named: "Arrow-up")
            } else if pctChange < 0.0 {
                detailView?.dirImage?.image = UIImage(named: "Arrow-down")
            } else {
                detailView?.dirImage?.image = nil
            }

            detailView?.changeLabel?.text = (itemData?["pct_change"] ?? "") + "%"
            detailView?.changeLabel?.textColor = (toDouble(itemData?["pct_change"]) >= 0.0) ? DARK_GREEN_COLOR : RED_COLOR

            if (itemUpdated?["pct_change"] as? NSNumber)?.boolValue ?? false {
                SpecialEffects.flashImage(detailView?.dirImage, with: color)
                SpecialEffects.flash(detailView?.changeLabel, with: color)
                itemUpdated?["pct_change"] = NSNumber(value: false)
            }

            detailView?.minLabel?.text = itemData?["min"]
            if (itemUpdated?["min"] as? NSNumber)?.boolValue ?? false {
                SpecialEffects.flash(detailView?.minLabel, with: color)
                itemUpdated?["min"] = NSNumber(value: false)
            }

            detailView?.maxLabel?.text = itemData?["max"]
            if (itemUpdated?["max"] as? NSNumber)?.boolValue ?? false {
                SpecialEffects.flash(detailView?.maxLabel, with: color)
                itemUpdated?["max"] = NSNumber(value: false)
            }

            detailView?.bidLabel?.text = itemData?["bid"]
            if (itemUpdated?["bid"] as? NSNumber)?.boolValue ?? false {
                SpecialEffects.flash(detailView?.bidLabel, with: color)
                itemUpdated?["bid"] = NSNumber(value: false)
            }

            detailView?.askLabel?.text = itemData?["ask"]
            if (itemUpdated?["ask"] as? NSNumber)?.boolValue ?? false {
                SpecialEffects.flash(detailView?.askLabel, with: color)
                itemUpdated?["ask"] = NSNumber(value: false)
            }

            detailView?.bidSizeLabel?.text = itemData?["bid_quantity"]
            if (itemUpdated?["bid_quantity"] as? NSNumber)?.boolValue ?? false {
                SpecialEffects.flash(detailView?.bidSizeLabel, with: color)
                itemUpdated?["bid_quantity"] = NSNumber(value: false)
            }

            detailView?.askSizeLabel?.text = itemData?["ask_quantity"]
            if (itemUpdated?["ask_quantity"] as? NSNumber)?.boolValue ?? false {
                SpecialEffects.flash(detailView?.askSizeLabel, with: color)
                itemUpdated?["ask_quantity"] = NSNumber(value: false)
            }

            detailView?.openLabel?.text = itemData?["open_price"]
            if (itemUpdated?["open_price"] as? NSNumber)?.boolValue ?? false {
                SpecialEffects.flash(detailView?.openLabel, with: color)
                itemUpdated?["open_price"] = NSNumber(value: false)
            }
        }
    }
    
    func toDouble(_ s: String?) -> Double {
        Double(s ?? "0") ?? 0
    }
    
    func toFloat(_ s: String?) -> Float {
        Float(s ?? "0") ?? 0
    }
}

// MARK: -
// MARK: DetailViewController extension
// MARK: -
// MARK: DetailViewController implementation
