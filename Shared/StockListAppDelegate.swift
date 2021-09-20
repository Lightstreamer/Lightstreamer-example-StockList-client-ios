//  Converted to Swift 5.4 by Swiftify v5.4.24488 - https://swiftify.com/
//
//  StockListAppDelegate.swift
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

@objc protocol StockListAppDelegate: NSObjectProtocol {
    // MARK: -
    // MARK: Properties
    var stockListController: StockListViewController? { get }
}