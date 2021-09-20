//  Converted to Swift 5.4 by Swiftify v5.4.24488 - https://swiftify.com/
//
//  Connector.swift
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

import Foundation
import LightstreamerClient

private var __sharedInstace: Connector? = nil
private let __lockQueue = DispatchQueue(label: "lightstreamer.Connector")

class Connector: NSObject, ClientDelegate {
    let client: LightstreamerClient


    // MARK: -
    // MARK: Properties

    var connected: Bool {
        return client.status.rawValue.hasPrefix("CONNECTED:")
    }

    var connectionStatus: String {
        return client.status.rawValue
    }

    // MARK: -
    // MARK: Singleton access
    @objc class func shared() -> Connector {
        if __sharedInstace == nil {
            __lockQueue.sync {
                if __sharedInstace == nil {
                    __sharedInstace = Connector()
                }
            }
        }

        return __sharedInstace!
    }
    
    @objc class func sharedConnector() -> Connector {
        Self.shared()
    }

    // MARK: -
    // MARK: Initialization

    override init() {
        client = LightstreamerClient(serverAddress: PUSH_SERVER_URL, adapterSet: ADAPTER_SET)
        super.init()
        client.addDelegate(self)
        
        #if os(watchOS)
        
        // On watchOS connections are extremely slow (for no apparent reason),
        // so we raise the timeout and force the HTTP streaming transport,
        // to reduce the number of connections required
        client.connectionOptions.retryDelay = 15_000
        client.connectionOptions.forcedTransport = .HTTP_STREAMING
        
        #endif
    }

    // MARK: -
    // MARK: Operations
    func connect() {
        print("Connector: connecting...")

        client.connect()
    }

    func subscribe(_ subscription: Subscription) {
        print("Connector: subscribing...")

        client.subscribe(subscription)
    }

    func unsubscribe(_ subscription: Subscription) {
        print("Connector: unsubscribing...")

        client.unsubscribe(subscription)
    }

    // MARK: -
    // MARK: Properties

    // MARK: -
    // MARK: Methods of ClientDelegate
    
    func clientDidRemoveDelegate(_ client: LightstreamerClient) {}
    func clientDidAddDelegate(_ client: LightstreamerClient) {}

    func client(_ client: LightstreamerClient, didChangeProperty property: String) {
        print("Connector: property changed: \(property)")
    }

    func client(_ client: LightstreamerClient, didChangeStatus status: LightstreamerClient.Status) {
        print("Connector: status changed: \(status)")
        let status = status.rawValue
        if status.hasPrefix("CONNECTED:") {
            NotificationCenter.default.post(name: NOTIFICATION_CONN_STATUS, object: self)
        } else if status.hasPrefix("DISCONNECTED:") {

            // The LightstreamerClient will reconnect automatically in this case.
            NotificationCenter.default.post(name: NOTIFICATION_CONN_STATUS, object: self)
        } else if status == "DISCONNECTED" {
            NotificationCenter.default.post(name: NOTIFICATION_CONN_STATUS, object: self)

            // In this case the session has been forcibly closed by the server,
            // the LightstreamerClient will not automatically reconnect, notify the observers
            NotificationCenter.default.post(name: NOTIFICATION_CONN_ENDED, object: self)
        }
    }

    func client(_ client: LightstreamerClient, didReceiveServerError errorCode: Int, withMessage errorMessage: String) {
        print(String(format: "Connector: server error: %ld - %@", errorCode, errorMessage))

        NotificationCenter.default.post(name: NOTIFICATION_CONN_STATUS, object: self)
    }
}
