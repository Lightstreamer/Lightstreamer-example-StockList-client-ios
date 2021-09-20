//  Converted to Swift 5.4 by Swiftify v5.4.24488 - https://swiftify.com/
//
//  SpecialEffects.swift
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

class SpecialEffects: NSObject {
    // MARK: -
    // MARK: UI element flashing
    @objc class func flash(_ label: UILabel?, with color: UIColor?) {
        label?.layer.backgroundColor = color?.cgColor
        if label?.tag == COLORED_LABEL_TAG {
            label?.textColor = UIColor.black
        }

        SpecialEffects.self.perform(#selector(unflashLabel(_:)), with: label, afterDelay: FLASH_DURATION)
    }

    @objc class func flashImage(_ imageView: UIImageView?, with color: UIColor?) {
        imageView?.backgroundColor = color

        SpecialEffects.self.perform(#selector(unflashImage(_:)), with: imageView, afterDelay: FLASH_DURATION)
    }

    // MARK: -
    // MARK: Internals

    @objc class func unflashLabel(_ label: UILabel?) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeIn)
        UIView.setAnimationDuration(FLASH_DURATION)

        label?.layer.backgroundColor = UIColor.clear.cgColor
        if label?.tag == COLORED_LABEL_TAG {
            label?.textColor = (Double(label?.text ?? "") ?? 0.0 >= 0.0) ? DARK_GREEN_COLOR : RED_COLOR
        }

        UIView.commitAnimations()
    }

    @objc class func unflashImage(_ imageView: UIImageView?) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeIn)
        UIView.setAnimationDuration(FLASH_DURATION)

        imageView?.backgroundColor = UIColor.clear

        UIView.commitAnimations()
    }
}
