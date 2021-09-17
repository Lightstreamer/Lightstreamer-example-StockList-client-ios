#  Swiftify HowTo - StockList Demo for iOS project

Once you open a project in the Swiftify Advanced Project Converter, you are prompted to configure Objective-C and Swift Bridging Header files.
This step is required for calling Objective-C code from Swift and vice versa.
The following files are generated and added to the project:

1. Objective-C Bridging Header file (`StockList Demo for iOS-Bridging-Header.h`).
This file contains a section called "Swiftify generated imports", which lists all imports from Objective-C files that were already converted to Swift.
These imports will be automatically available to all `.swift` files in your project.

2. Precompiled Header file (`StockList Demo for iOS-Prefix.pch`).
We are using the PCH file to conveniently import the Swift Bridging Header file (`StockList_Demo_for_iOS-Swift.h`)

3. A Swift conversion of the original PCH file (`StockList Demo for iOS-Prefix.swift`).
This file is always created to force generation of the Swift Bridging Header file (`StockList_Demo_for_iOS-Swift.h`) by Xcode itself, every time the project is compiled successfully.
Once your project contains at least one Swift file, this file can be safely deleted for most projects.

4. This Readme file (`Swiftify.README.md`).
Once you understand the changes made by Swiftify, you can turn off the generation of this Readme file by going to Swiftify for Xcode => Preferences => Converter and toggling the corresponding checkbox.

**Important Note**: Both Apple and Swiftify recommend that you migrate your project gradually, on a per-file basis.
We do not guarantee error-free conversion, but our goal is to save your time.
By converting one file at a time, you will have to make a few fixes per source file,
rather than fixing hundreds of issues in the whole project.

Refer to the [this article](https://medium.com/swiftify/converting-your-project-to-swift-with-swiftifys-advanced-project-converter-b9eb051ae504) for best practices to migrate your project using the Advanced Project Converter.

You are welcome to report any converter issues at our [GitHub Issue Tracker](https://github.com/Swiftify-Corp/Swiftify/issues).
