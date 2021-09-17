//  Converted to Swift 5.4 by Swiftify v5.4.24488 - https://swiftify.com/
//
//  StockListViewController.swift
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

class StockListViewController: UITableViewController, SubscriptionDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate {
    
    let lockQueue = DispatchQueue(label: "lightstreamer.StockListViewController")
    
    var stockListView: StockListView?
    var subscribed = false
    var subscription: Subscription?
    var selectedRow: IndexPath?
    // Multiple-item data structures: each item has a second-level dictionary.
    // They store fields data and which fields have been updated
    var itemUpdated = [UInt : [String: Bool]]()
    var itemData = [UInt : [String : String?]]()
    // List of rows marked to be reloaded by the table
    var rowsToBeReloaded = Set<IndexPath>()
    var infoButton: UIBarButtonItem?
    var popoverInfoController: UIPopoverController?
    var statusButton: UIBarButtonItem?
    var popoverStatusController: UIPopoverController?
    var detailController: DetailViewController?

    // MARK: -
    // MARK: User actions

    // MARK: -
    // MARK: Lightstreamer connection status management

    // MARK: -
    // MARK: Internals

    // MARK: -
    // MARK: Initialization
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        title = "Lightstreamer Stock List"
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "Lightstreamer Stock List"
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        title = "Lightstreamer Stock List"
    }
    
    // MARK: -
    // MARK: User actions

    @objc func infoTapped() {
        if DEVICE_IPAD {

            // If the Info popover is open close it
            if popoverInfoController != nil {
                popoverInfoController?.dismiss(animated: true)
                popoverInfoController = nil
                return
            }

            // If the Status popover is open close it
            if popoverStatusController != nil {
                popoverStatusController?.dismiss(animated: true)
                popoverStatusController = nil
            }

            // Open the Info popover
            let infoController = InfoViewController()
            popoverInfoController = UIPopoverController(contentViewController: infoController)

            popoverInfoController?.contentSize = CGSize(width: INFO_IPAD_WIDTH, height: INFO_IPAD_HEIGHT)
            popoverInfoController?.delegate = self

            if let rightBarButtonItem = navigationItem.rightBarButtonItem {
                popoverInfoController?.present(from: rightBarButtonItem, permittedArrowDirections: .any, animated: true)
            }
        } else {
            let infoController = InfoViewController()
            navigationController?.pushViewController(infoController, animated: true)
        }
    }

    @objc func statusTapped() {
        if DEVICE_IPAD {

            // If the Status popover is open close it
            if popoverStatusController != nil {
                popoverStatusController?.dismiss(animated: true)
                popoverStatusController = nil
                return
            }

            // If the Info popover is open close it
            if popoverInfoController != nil {
                popoverInfoController?.dismiss(animated: true)
                popoverInfoController = nil
            }

            // Open the Status popover
            let statusController = StatusViewController()
            popoverStatusController = UIPopoverController(contentViewController: statusController)

            popoverStatusController?.contentSize = CGSize(width: STATUS_IPAD_WIDTH, height: STATUS_IPAD_HEIGHT)
            popoverStatusController?.delegate = self

            if let leftBarButtonItem = navigationItem.leftBarButtonItem {
                popoverStatusController?.present(from: leftBarButtonItem, permittedArrowDirections: .any, animated: true)
            }
        } else {
            let statusController = StatusViewController()
            navigationController?.pushViewController(statusController, animated: true)
        }
    }

    // MARK: -
    // MARK: Methods of UIViewController

    override func loadView() {
        let niblets = Bundle.main.loadNibNamed(DEVICE_XIB("StockListView"), owner: self, options: nil)
        stockListView = niblets?.last as? StockListView

        tableView = stockListView?.table
        view = stockListView
        
        infoButton = UIBarButtonItem(image: UIImage(named: "Info"), style: .plain, target: self, action: #selector(infoTapped))
        infoButton?.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = infoButton

        statusButton = UIBarButtonItem(image: UIImage(named: "Icon-disconnected"), style: .plain, target: self, action: #selector(statusTapped))
        statusButton?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = statusButton

        navigationController?.delegate = self

        if DEVICE_IPAD {

            // On the iPad we preselect the first row,
            // since the detail view is always visible
            selectedRow = IndexPath(row: 0, section: 0)
            detailController = (UIApplication.shared.delegate as? AppDelegate_iPad)?.detailController
        }

        // We use the notification center to know when the
        // connection changes status
        NotificationCenter.default.addObserver(self, selector: #selector(connectionStatusChanged), name: NOTIFICATION_CONN_STATUS, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectionEnded), name: NOTIFICATION_CONN_ENDED, object: nil)

        // Start connection (executes in background)
        Connector.shared().connect()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if DEVICE_IPAD {
            return .landscape
        } else {
            return .portrait
        }
    }

    // MARK: -
    // MARK: Methods of UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NUMBER_OF_ITEMS
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Prepare the table cell
        var cell = tableView.dequeueReusableCell(withIdentifier: "StockListCell") as? StockListCell
        if cell == nil {
            let niblets = Bundle.main.loadNibNamed(DEVICE_XIB("StockListCell"), owner: self, options: nil)
            cell = niblets?.last as? StockListCell
        }

        // Retrieve the item's data structures
        var item: [String : String?]! = nil
        var updated: [String : Bool]! = nil
        lockQueue.sync {
            item = itemData[UInt(indexPath.row)]
            updated = itemUpdated[UInt(indexPath.row)]
        }
        
        if let item = item {

            // Update the cell appropriately
            let colorName = item["color"] as? String
            var color: UIColor? = nil
            if colorName == "green" {
                color = GREEN_COLOR
            } else if colorName == "orange" {
                color = ORANGE_COLOR
            } else {
                color = UIColor.white
            }

            cell?.nameLabel?.text = item["stock_name"] as? String
            if updated?["stock_name"] ?? false {
                if !stockListView!.table!.isDragging {
                    SpecialEffects.flash(cell?.nameLabel, with: color)
                }

                updated?["stock_name"] = false
            }

            cell?.lastLabel?.text = item["last_price"] as? String
            if updated?["last_price"] ?? false {
                if !stockListView!.table!.isDragging {
                    SpecialEffects.flash(cell?.lastLabel, with: color)
                }

                updated?["last_price"] = false
            }

            cell?.timeLabel?.text = item["time"] as? String
            if updated?["time"] ?? false {
                if !stockListView!.table!.isDragging {
                    SpecialEffects.flash(cell?.timeLabel, with: color)
                }

                updated?["time"] = false
            }

            let pctChange = Double((item["pct_change"] ?? "0") ?? "0") ?? 0.0
            if pctChange > 0.0 {
                cell?.dirImage?.image = UIImage(named: "Arrow-up")
            } else if pctChange < 0.0 {
                cell?.dirImage?.image = UIImage(named: "Arrow-down")
            } else {
                cell?.dirImage?.image = nil
            }

            if let object = item["pct_change"] {
                cell?.changeLabel?.text = String(format: "%@%%", object!)
            }
            cell?.changeLabel?.textColor = (Double((item["pct_change"] ?? "0") ?? "0") ?? 0.0 >= 0.0) ? DARK_GREEN_COLOR : RED_COLOR

            if updated?["pct_change"] ?? false {
                if !stockListView!.table!.isDragging {
                    SpecialEffects.flashImage(cell?.dirImage, with: color)
                    SpecialEffects.flash(cell?.changeLabel, with: color)
                }

                updated?["pct_change"] = false
            }
        }

        // Update the cell text colors appropriately
        if indexPath == selectedRow {
            cell?.nameLabel?.textColor = SELECTED_TEXT_COLOR
            cell?.lastLabel?.textColor = SELECTED_TEXT_COLOR
            cell?.timeLabel?.textColor = SELECTED_TEXT_COLOR
        } else {
            cell?.nameLabel?.textColor = DEFAULT_TEXT_COLOR
            cell?.lastLabel?.textColor = DEFAULT_TEXT_COLOR
            cell?.timeLabel?.textColor = DEFAULT_TEXT_COLOR
        }

        return cell!
    }

    // MARK: -
    // MARK: Methods of UITableViewDelegate

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        // Mark the row to be reloaded
        lockQueue.sync {
            if selectedRow != nil {
                rowsToBeReloaded.insert(selectedRow!)
            }

            rowsToBeReloaded.insert(indexPath)
        }

        selectedRow = indexPath

        // Update the table view
        reloadTableRows()

        // On the iPhone the Detail View Controller is created on demand and pushed with
        // the navigation controller
        if detailController == nil {
            detailController = DetailViewController()

            // Ensure the view is loaded
            detailController?.view
        }

        // Update the item on the detail controller
        detailController?.changeItem(TABLE_ITEMS[indexPath.row])

        if !DEVICE_IPAD {

            // On the iPhone the detail view controller may be already visible,
            // if it is not just push it
            if (navigationController?.viewControllers.count ?? 0) == 1 {
                if let detailController = detailController {
                    navigationController?.pushViewController(detailController, animated: true)
                }
            }
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let niblets = Bundle.main.loadNibNamed(DEVICE_XIB("StockListSection"), owner: self, options: nil)

        return niblets?.last as? UIView
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath == selectedRow {
            cell.backgroundColor = SELECTED_ROW_COLOR
        } else if indexPath.row % 2 == 0 {
            cell.backgroundColor = LIGHT_ROW_COLOR
        } else {
            cell.backgroundColor = DARK_ROW_COLOR
        }
    }

    // MARK: -
    // MARK: Methods of UIPopoverControllerDelegate

    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController) {
        if popoverController == popoverInfoController {
            popoverInfoController = nil
        } else if popoverController == popoverStatusController {
            popoverStatusController = nil
        }
    }

    // MARK: -
    // MARK: Methods of UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if !DEVICE_IPAD {

            // Remove selection when coming back from detail view
            if viewController == self {

                // Mark the row to be reloaded
                lockQueue.sync {
                    if selectedRow != nil {
                        rowsToBeReloaded.insert(selectedRow!)
                    }
                }

                selectedRow = nil

                // Update the table view
                reloadTableRows()
            }
        }
    }

    // MARK: -
    // MARK: Lighstreamer connection status management

    @objc func connectionStatusChanged() {
        // This method is always called from a background thread

        // Check if we need to subscribe
        let needsSubscription = !subscribed && Connector.shared().connected

        DispatchQueue.main.async(execute: { [self] in

            // Update connection status icon
            if Connector.shared().connectionStatus.hasPrefix("DISCONNECTED") {
                navigationItem.leftBarButtonItem?.image = UIImage(named: "Icon-disconnected")
            } else if Connector.shared().connectionStatus.hasPrefix("CONNECTING") {
                navigationItem.leftBarButtonItem?.image = UIImage(named: "Icon-connecting")
            } else if Connector.shared().connectionStatus.hasPrefix("STALLED") {
                navigationItem.leftBarButtonItem?.image = UIImage(named: "Icon-stalled")
            } else if Connector.shared().connectionStatus.hasPrefix("CONNECTED") && Connector.shared().connectionStatus.hasSuffix("POLLING") {
                navigationItem.leftBarButtonItem?.image = UIImage(named: "Icon-polling")
            } else if Connector.shared().connectionStatus.hasPrefix("CONNECTED") && Connector.shared().connectionStatus.hasSuffix("WS-STREAMING") {
                navigationItem.leftBarButtonItem?.image = UIImage(named: "Icon-WS-streaming")
            } else if Connector.shared().connectionStatus.hasPrefix("CONNECTED") && Connector.shared().connectionStatus.hasSuffix("HTTP-STREAMING") {
                navigationItem.leftBarButtonItem?.image = UIImage(named: "Icon-HTTP-streaming")
            }

            // If the detail controller is visible, set the item on the detail view controller,
            // so that it can do its own subscription
            if needsSubscription && (DEVICE_IPAD || ((navigationController?.viewControllers.count ?? 0) > 1)) {
                detailController?.changeItem(TABLE_ITEMS[selectedRow?.row ?? 0])
            }
        })

        // Check if we need to subscribe
        if needsSubscription {
            subscribed = true

            print("StockListViewController: subscribing table...")

            // The LSLightstreamerClient will reconnect and resubscribe automatically
            subscription = Subscription(subscriptionMode: .MERGE, items: TABLE_ITEMS, fields: LIST_FIELDS)
            subscription?.dataAdapter = DATA_ADAPTER
            subscription?.requestedSnapshot = .yes
            subscription?.addDelegate(self)

            Connector.shared().subscribe(subscription!)
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
    // MARK: Internals

    func reloadTableRows() {
        // This method is always called from the main thread

        var rows: [IndexPath]? = nil
        lockQueue.sync {
            rows = [IndexPath]()

            for indexPath in self.rowsToBeReloaded {
                rows?.append(indexPath)
            }

            self.rowsToBeReloaded.removeAll()
        }

        // Ask the table to reload the marked rows
        if let rows = rows {
            stockListView?.table?.reloadRows(at: rows, with: .none)
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

        let itemPosition = UInt(itemUpdate.itemPos)

        // Check and prepare the item's data structures
        var item: [String : String?]! = nil
        var updated: [String : Bool]! = nil
        lockQueue.sync {
            item = itemData[itemPosition - 1]
            if item == nil {
                item = [String : String?](minimumCapacity: NUMBER_OF_LIST_FIELDS)
                itemData[itemPosition - 1] = item
            }

            updated = self.itemUpdated[itemPosition - 1]
            if updated == nil {
                updated = [String : Bool](minimumCapacity: NUMBER_OF_LIST_FIELDS)
                itemUpdated[itemPosition - 1] = updated
            }
        }

        var previousLastPrice = 0.0
        for fieldName in LIST_FIELDS {

            // Save previous last price to choose blink color later
            if fieldName == "last_price" {
                previousLastPrice = Double((item[fieldName] ?? "0") ?? "0") ?? 0.0
            }

            // Store the updated field in the item's data structures
            let value = itemUpdate.value(withFieldName: fieldName)

            if value != "" {
                item?[fieldName] = value
            } else {
                item?[fieldName] = nil
            }

            if itemUpdate.isValueChanged(withFieldName: fieldName) {
                updated?[fieldName] = true
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
            itemData[itemPosition - 1] = item
            itemUpdated[itemPosition - 1] = updated
        }
        
        // Mark rows to be reload
        lockQueue.sync {
            rowsToBeReloaded.insert(IndexPath(row: Int(itemPosition) - 1, section: 0))
        }

        DispatchQueue.main.async(execute: { [self] in

            // Update the table view
            reloadTableRows()
        })
    }
}

// MARK: -
// MARK: StockListViewController extension
// MARK: -
// MARK: StockListViewController implementation
