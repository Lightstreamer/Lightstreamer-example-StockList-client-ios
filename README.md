# Lightstreamer - Stock-List Demo - iOS Client

<!-- START DESCRIPTION lightstreamer-example-stocklist-client-ios -->

This project contains an example of an application for iPhone and iPad that employs the [Lightstreamer Swift Client library](http://www.lightstreamer.com/api/ls-swift-client/latest/). The application also includes a WatchKit extension.

A version with full support for mobile push notifications (MPN) is also available: [Lightstreamer - Stock-List Demo with APNs Push Notifications - iOS Client](https://github.com/Lightstreamer/Lightstreamer-example-MPNStockList-client-ios).

![screenshot](screenshot_newlarge.png)<br>

## Details

This app, compatible with both iPhone and iPad, is an Swift version of the [Stock-List Demos](https://github.com/Lightstreamer/Lightstreamer-example-Stocklist-client-javascript).<br>

This app uses the <b>Swift Client API for Lightstreamer</b> to handle the communications with Lightstreamer Server. A simple user interface is implemented to display the real-time data received from Lightstreamer Server.<br>

## Build

A full Xcode project, ready for compilation of the app sources, is provided. Please recall that you need a valid iOS Developer Program membership to run or debug your app on a test device.

### Compile and Run

* Create an *app ID* on the [Apple Developer Center](https://developer.apple.com/membercenter/index.action).
* Create and install an appropriate provisioning profile for the app ID above and your test device, on the Apple Developer Center.
* Set the app ID above as the *Bundle Identifier* of the Xcode project of the app.
* Set the IP address of your local Lightstreamer Server in the constant `PUSH_SERVER_URL`, defined in `Shared/Constants.swift`; a ":port" part can also be added.
* Follow the installation instructions for the Data and Metadata adapters required by the demo, detailed in the [Lightstreamer - Stock-List Demo - Java Adapter](https://github.com/Lightstreamer/Lightstreamer-example-StockList-adapter-java) project.

Done this, the app should run correctly on your test device and connect to your server.

## See Also

### Lightstreamer Adapters Needed by This Demo Client

* [Lightstreamer - Stock- List Demo - Java Adapter](https://github.com/Lightstreamer/Lightstreamer-example-Stocklist-adapter-java)
* [Lightstreamer - Reusable Metadata Adapters- Java Adapter](https://github.com/Lightstreamer/Lightstreamer-example-ReusableMetadata-adapter-java)

### Related Projects

* [Lightstreamer - Stock-List Demos - HTML Clients](https://github.com/Lightstreamer/Lightstreamer-example-Stocklist-client-javascript)
* [Lightstreamer - Stock-List Demo with APNs Push Notifications - iOS Client](https://github.com/Lightstreamer/Lightstreamer-example-MPNStockList-client-ios)
* [Lightstreamer - Stock-List Demo - Android Client](https://github.com/Lightstreamer/Lightstreamer-example-AdvStockList-client-android)
* [Lightstreamer - Basic Stock-List Demo - OS X Client](https://github.com/Lightstreamer/Lightstreamer-example-StockList-client-osx)
* [Lightstreamer - Basic Stock-List Demo - Windows Phone Client](https://github.com/Lightstreamer/Lightstreamer-example-StockList-client-winphone)

## Lightstreamer Compatibility Notes

* Code compatible with Lightstreamer Swift Client Library version 6.0 or newer.
* For Lightstreamer Server version 7.4 or greater. Ensure that iOS and/or watchOS Client SDK is supported by Lightstreamer Server license configuration, depending on where the demo will be run.
* For a version of this example compatible with Lightstreamer iOS and watchOS Client SDKs versions up to 5, please refer to [this tag](https://github.com/Lightstreamer/Lightstreamer-example-StockList-client-ios/tree/latest-for-client-5.x).
* For a version of this example compatible with Lightstreamer iOS and watchOS Client SDKs versions up to 4, please refer to [this tag](https://github.com/Lightstreamer/Lightstreamer-example-StockList-client-ios/tree/latest-for-client-4.x).
