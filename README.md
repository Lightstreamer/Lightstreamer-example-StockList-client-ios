# Lightstreamer - Stock-List Demo - iOS Client

<!-- START DESCRIPTION lightstreamer-example-stocklist-client-ios -->

This project contains an example of an application for iPhone and iPad that employs the [Lightstreamer iOS Client library](http://www.lightstreamer.com/docs/client_ios_api/index.html).

A version with full support for mobile push notifications (MPN) is also available: [Lightstreamer - Stock-List Demo with APNs Push Notifications - iOS Client](https://github.com/Weswit/Lightstreamer-example-MPNStockList-client-ios).

## Live Demo

[![screenshot](screenshot_newlarge.png)](https://itunes.apple.com/us/app/lightstreamer-stock-list/id930445387?mt=8)<br>
###[![](http://demos.lightstreamer.com/site/img/play.png) View live demo](https://itunes.apple.com/us/app/lightstreamer-stock-list/id930445387?mt=8)<br>

## Details

This app, compatible with both iPhone and iPad, is an Objective-C version of the [Stock-List Demos](https://github.com/Weswit/Lightstreamer-example-Stocklist-client-javascript).<br>

This app uses the <b>iOS Client API for Lightstreamer</b> to handle the communications with Lightstreamer Server. A simple user interface is implemented to display the real-time data received from Lightstreamer Server.<br>

## Install

Binaries for the application are not provided, but it may be downloaded from the App Store at [this address](https://itunes.apple.com/us/app/lightstreamer-stock-list/id930445387?mt=8). The downloaded app will connect to Lightstreamer's online demo server.

## Build

A full Xcode project specification, ready for compilation of the app sources, is provided. Please recall that you need a valid iOS Developer Program membership to run or debug your app on a test device.

### Getting Started

Before you can build this demo, you should complete this project with the Lighstreamer iOS Client library. Follow these steps:

* Drop into the `Lightstreamer client for iOS/lib` folder of this project the *Lightstreamer_iOS_client.a* file from the `/DOCS-SDKs/sdk_client_ios/lib` of [Lightstreamer distribution version 6.0 or greater](http://www.lightstreamer.com/download).
* Drop into the `Lightstreamer client for iOS/include` folder of this project all the include files from the `/DOCS-SDKs/sdk_client_ios/include` of [latest Lightstreamer distribution](http://www.lightstreamer.com/download).

Done this, the project should compile with no errors.

### Compile and Run

* Create an *app ID* on the [Apple Developer Center](https://developer.apple.com/membercenter/index.action).
* Create and install an appropriate provisioning profile for the app ID above and your test device, on the Apple Developer Center.
* Set the app ID above as the *Bundle Identifier* of the Xcode project of the app.
* Set the IP address of your local Lightstreamer Server in the constant `PUSH_SERVER_URL`, defined in `Shared/Constants.h`; a ":port" part can also be added.
* Follow the installation instructions for the Data and Metadata adapters required by the demo, detailed in the [Lightstreamer - Stock-List Demo - Java Adapter](https://github.com/Weswit/Lightstreamer-example-StockList-adapter-java) project.

Done this, the app should run correctly on your test device and connect to your server.

## See Also

### Lightstreamer Adapters Needed by This Demo Client

* [Lightstreamer - Stock- List Demo - Java Adapter](https://github.com/Weswit/Lightstreamer-example-Stocklist-adapter-java)
* [Lightstreamer - Reusable Metadata Adapters- Java Adapter](https://github.com/Weswit/Lightstreamer-example-ReusableMetadata-adapter-java)

### Related Projects

* [Lightstreamer - Stock-List Demos - HTML Clients](https://github.com/Weswit/Lightstreamer-example-Stocklist-client-javascript)
* [Lightstreamer - Stock-List Demo with APNs Push Notifications - iOS Client](https://github.com/Weswit/Lightstreamer-example-MPNStockList-client-ios)
* [Lightstreamer - Stock-List Demo - Android Client](https://github.com/Weswit/Lightstreamer-example-AdvStockList-client-android)
* [Lightstreamer - Basic Stock-List Demo - OS X Client](https://github.com/Weswit/Lightstreamer-example-StockList-client-osx)
* [Lightstreamer - Basic Stock-List Demo - Windows Phone Client](https://github.com/Weswit/Lightstreamer-example-StockList-client-winphone)

## Lightstreamer Compatibility Notes

* Compatible with Lightstreamer iOS Client Library version 1.2 or newer.
* For Lightstreamer Allegro (+ iOS Client API support), Presto, Vivace.
