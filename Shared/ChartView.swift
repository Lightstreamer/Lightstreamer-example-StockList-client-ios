//  Converted to Swift 5.4 by Swiftify v5.4.24488 - https://swiftify.com/
//
//  ChartView.swift
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

import CoreText
import UIKit

class ChartView: UIView {
    let lockQueue = DispatchQueue(label: "lightstreamer.ChartView")
    var data: [AnyHashable]?





    // MARK: -
    // MARK: Properties

    private var _min: Float = 0.0
    @objc var min: Float {
        get {
            return _min
        }
        set(min) {
            lockQueue.sync {
                _min = min
            }

            setNeedsDisplay()
        }
    }

    private var _max: Float = 0.0
    @objc var max: Float {
        get {
            return _max
        }
        set(max) {
            lockQueue.sync {
                _max = max
            }

            setNeedsDisplay()
        }
    }

    private var _begin: TimeInterval = 0.0
    @objc var begin: TimeInterval {
        get {
            return _begin
        }
        set(begin) {
            lockQueue.sync {
                _begin = begin
            }

            setNeedsDisplay()
        }
    }

    private var _end: TimeInterval = 0.0
    @objc var end: TimeInterval {
        get {
            return _end
        }
        set(end) {
            lockQueue.sync {
                _end = end
            }

            setNeedsDisplay()
        }
    }

    // MARK: -
    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization
        data = []

        clearsContextBeforeDrawing = true
        clipsToBounds = true
    }

    // MARK: -
    // MARK: Data management
    @objc func addValue(_ value: Float, withTime time: TimeInterval) {
        lockQueue.sync {

            // Add value, keeping the array sorted
            let point = NSValue(cgPoint: CGPoint(x: CGFloat(time), y: CGFloat(value)))

            var index = (data as NSArray?)?.index(of: point, inSortedRange: NSRange(location: 0, length: data?.count ?? 0), options: [.lastEqual, .insertionIndex], usingComparator: { obj1, obj2 in
                let point1 = (obj1 as? NSValue)?.cgPointValue
                let point2 = (obj2 as? NSValue)?.cgPointValue

                if (point1?.x ?? 0.0) < (point2?.x ?? 0.0) {
                    return .orderedAscending
                } else if (point1?.x ?? 0.0) > (point2?.x ?? 0.0) {
                    return .orderedDescending
                } else {
                    return .orderedSame
                }
            }) ?? 0

            data?.insert(NSValue(cgPoint: CGPoint(x: CGFloat(time), y: CGFloat(value))), at: index)

            // Strip out values out of time range
            let begin = NSValue(cgPoint: CGPoint(x: CGFloat(self.begin), y: 0.0))

            index = (data as NSArray?)?.index(of: begin, inSortedRange: NSRange(location: 0, length: data?.count ?? 0), options: [.firstEqual, .insertionIndex], usingComparator: { obj1, obj2 in
                let point1 = (obj1 as? NSValue)?.cgPointValue
                let point2 = (obj2 as? NSValue)?.cgPointValue

                if (point1?.x ?? 0.0) < (point2?.x ?? 0.0) {
                    return .orderedAscending
                } else if (point1?.x ?? 0.0) > (point2?.x ?? 0.0) {
                    return .orderedDescending
                } else {
                    return .orderedSame
                }
            }) ?? 0

            if index >= 1 {
                for deletionIndex in NSIndexSet(indexesIn: NSRange(location: 0, length: index)).reversed() { data?.remove(at: deletionIndex) }
            }

            let end = NSValue(cgPoint: CGPoint(x: CGFloat(self.end), y: 0.0))

            index = (data as NSArray?)?.index(of: end, inSortedRange: NSRange(location: 0, length: data?.count ?? 0), options: [.lastEqual, .insertionIndex], usingComparator: { obj1, obj2 in
                let point1 = (obj1 as? NSValue)?.cgPointValue
                let point2 = (obj2 as? NSValue)?.cgPointValue

                if (point1?.x ?? 0.0) < (point2?.x ?? 0.0) {
                    return .orderedAscending
                } else if (point1?.x ?? 0.0) > (point2?.x ?? 0.0) {
                    return .orderedDescending
                } else {
                    return .orderedSame
                }
            }) ?? 0

            if index < (data?.count ?? 0) {
                for deletionIndex in NSIndexSet(indexesIn: NSRange(location: index, length: (data?.count ?? 0) - index)).reversed() { data?.remove(at: deletionIndex) }
            }
        }

        setNeedsDisplay()
    }

    @objc func clearValues() {
        lockQueue.sync {
            data?.removeAll()
        }

        setNeedsDisplay()
    }

    // MARK: -
    // MARK: Coordinates managements
    @objc func value(at point: CGPoint) -> CGPoint {
        let x = Float(point.x)
        let y = Float(point.y)

        let size = frame.size

        let propX = Float((Double(x) - LEFT_AXIS_MARGIN) / (Double(size.width) - LEFT_AXIS_MARGIN - RIGHT_MARGIN))
        let propY = Float((Double(size.height) - BOTTOM_AXIS_MARGIN - Double(y)) / (Double(size.height) - BOTTOM_AXIS_MARGIN))

        let time = Float(begin) + propX * Float((end - begin))
        let value = min + propY * (max - min)

        return CGPoint(x: CGFloat(time), y: CGFloat(value))
    }

    func point(forValue point: CGPoint) -> CGPoint {
        let time = TimeInterval(point.x)
        let value = Float(point.y)

        let deltaX = Float(time - begin)
        let deltaY = value - min

        let propX = deltaX / Float((end - begin))
        let propY = deltaY / (max - min)

        let size = frame.size

        var x = Float(LEFT_AXIS_MARGIN + ((Double(size.width) - LEFT_AXIS_MARGIN - RIGHT_MARGIN) * Double(propX)))
        var y = Float((Double(size.height) - BOTTOM_AXIS_MARGIN) - ((Double(size.height) - BOTTOM_AXIS_MARGIN) * Double(propY)))

        if Double(x) < LEFT_AXIS_MARGIN {
            x = Float(LEFT_AXIS_MARGIN)
        }

        if CGFloat(x) >= size.width {
            x = Float(size.width)
        }

        if y < 0.0 {
            y = 0.0
        }

        if Double(y) >= (Double(size.height) - BOTTOM_AXIS_MARGIN) {
            y = Float((Double(size.height) - BOTTOM_AXIS_MARGIN))
        }

        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }

    // MARK: -
    // MARK: Properties

    // MARK: -
    // MARK: Drawing

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let size = frame.size
        let context = UIGraphicsGetCurrentContext()

        let sysFont = CTFontCreateUIFontForLanguage(.kCTFontSystemFontType, CGFloat(FONT_SIZE), nil)
        let sysBoldFont = CTFontCreateUIFontForLanguage(.emphasizedSystem, CGFloat(FONT_SIZE), nil)

        let transform = CGAffineTransform(translationX: 0.0, y: size.height)
        let transform2 = transform.scaledBy(x: 1.0, y: -1.0)
        context?.textMatrix = transform2

        lockQueue.sync {

            // Draw the chart background
            context?.setFillColor(CHART_BACKGROUND_COLOR.cgColor)
            context?.fill(CGRect(x: CGFloat(LEFT_AXIS_MARGIN), y: 0.0, width: CGFloat(Double(size.width) - LEFT_AXIS_MARGIN), height: CGFloat(Double(size.height) - BOTTOM_AXIS_MARGIN)))

            // Draw the two axis
            context?.setStrokeColor(AXIS_LINE_COLOR.cgColor)
            context?.setLineWidth(CGFloat(AXIS_LINE_WIDTH))

            context?.move(to: CGPoint(x: CGFloat(LEFT_AXIS_MARGIN), y: 0.0))
            context?.addLine(to: CGPoint(x: CGFloat(LEFT_AXIS_MARGIN), y: size.height))
            context?.strokePath()

            context?.move(to: CGPoint(x: 0.0, y: CGFloat(Double(size.height) - BOTTOM_AXIS_MARGIN)))
            context?.addLine(to: CGPoint(x: size.width, y: CGFloat(Double(size.height) - BOTTOM_AXIS_MARGIN)))
            context?.strokePath()

            // Draw integer lines
            context?.setStrokeColor(INTEGER_LINE_COLOR.cgColor)
            context?.setLineWidth(CGFloat(INTEGER_LINE_WIDTH))
            var line: CTLine? = nil

            var attributesDict: [AnyHashable : Any]? = nil
            if let sysFont = sysFont {
                attributesDict = [
                    kCTFontAttributeName : sysFont,
                    kCTForegroundColorAttributeName : INTEGER_LABEL_COLOR.cgColor
                ]
            }

            let dashPhase: Float = 0.0
            let dashLengths = [CGFloat(10.0), CGFloat(5.0)]
            context?.setLineDash(phase: CGFloat(dashPhase), lengths: dashLengths)

            var current = Int(min + 1.0)
            while Float(current) < max {

                // Compute position
                let point = self.point(forValue: CGPoint(x: 0.0, y: CGFloat(current)))
                let y = Float(point.y)

                context?.move(to: CGPoint(x: CGFloat(LEFT_AXIS_MARGIN), y: CGFloat(y)))
                context?.addLine(to: CGPoint(x: size.width, y: CGFloat(y)))
                context?.strokePath()

                // Draw label
                if (Double(y) > FONT_SIZE + 5.0) && (Double(y) < (Double(size.height) - BOTTOM_AXIS_MARGIN - FONT_SIZE - 5.0)) {
                    let intLabel = String(format: "%7.2f", Float(current))
                    let intLabelAttr = NSAttributedString(string: intLabel, attributes: attributesDict as? [NSAttributedString.Key : Any])
                    context?.textPosition = CGPoint(x: 0.0, y: CGFloat(y))

                    let line = CTLineCreateWithAttributedString(intLabelAttr as CFAttributedString)
                    if let context = context {
                        CTLineDraw(line, context)
                    }
                }

                current += 1
            }

            // Draw the Y axis labels
            if let sysBoldFont = sysBoldFont {
                attributesDict = [
                    kCTFontAttributeName : sysBoldFont,
                    kCTForegroundColorAttributeName : AXIS_LABEL_COLOR.cgColor
                ]
            }

            let maxY = Float(FONT_SIZE)
            let maxLabel = String(format: "%7.2f", max)
            let maxLabelAttr = NSAttributedString(string: maxLabel, attributes: attributesDict as? [NSAttributedString.Key : Any])
            context?.textPosition = CGPoint(x: 0.0, y: CGFloat(maxY))
            line = CTLineCreateWithAttributedString(maxLabelAttr as CFAttributedString)
            if let context = context {
                CTLineDraw(line!, context)
            }

            let minY = Float(Double(size.height) - BOTTOM_AXIS_MARGIN - 5.0)
            let minLabel = String(format: "%7.2f", min)
            let minLabelAttr = NSAttributedString(string: minLabel, attributes: attributesDict as? [NSAttributedString.Key : Any])
            context?.textPosition = CGPoint(x: 0.0, y: CGFloat(minY))
            line = CTLineCreateWithAttributedString(minLabelAttr as CFAttributedString)
            if let context = context {
                CTLineDraw(line!, context)
            }

            // Draw the X axis labels
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"

            let beginLabel = formatter.string(from: Date(timeIntervalSinceReferenceDate: begin))
            let beginLabelAttr = NSAttributedString(string: beginLabel, attributes: attributesDict as? [NSAttributedString.Key : Any])
            context?.textPosition = CGPoint(x: CGFloat(LEFT_AXIS_MARGIN + 5.0), y: size.height - 5.0)
            line = CTLineCreateWithAttributedString(beginLabelAttr as CFAttributedString)
            if let context = context {
                CTLineDraw(line!, context)
            }

            let middleLabel = formatter.string(from: Date(timeIntervalSinceReferenceDate: (begin + end) / 2.0))
            let middleLabelAttr = NSAttributedString(string: middleLabel, attributes: attributesDict as? [NSAttributedString.Key : Any])
            context?.textPosition = CGPoint(x: CGFloat(LEFT_AXIS_MARGIN + ((Double(size.width) - LEFT_AXIS_MARGIN) / 2.0) - Double((middleLabelAttr.size().width / 2.0))), y: size.height - 5.0)
            line = CTLineCreateWithAttributedString(middleLabelAttr as CFAttributedString)
            if let context = context {
                CTLineDraw(line!, context)
            }

            let endLabel = formatter.string(from: Date(timeIntervalSinceReferenceDate: end))
            let endLabelAttr = NSAttributedString(string: endLabel, attributes: attributesDict as? [NSAttributedString.Key : Any])
            context?.textPosition = CGPoint(x: size.width - endLabelAttr.size().width, y: size.height - 5.0)
            line = CTLineCreateWithAttributedString(endLabelAttr as CFAttributedString)
            if let context = context {
                CTLineDraw(line!, context)
            }

            // Draw data
            context?.setStrokeColor(VALUE_LINE_COLOR.cgColor)
            context?.setLineWidth(CGFloat(VALUE_LINE_WIDTH))
            context?.setLineDash(phase: 0.0, lengths: [])

            var lastValue: Float = 0.0
            var lastY: Float = 0.0
            var first = true

            for pointValue in data ?? [] {
                guard let pointValue = pointValue as? NSValue else {
                    continue
                }
                let point = self.point(forValue: pointValue.cgPointValue)
                let x = Float(point.x)
                let y = Float(point.y)

                lastValue = Float(pointValue.cgPointValue.y)
                lastY = y

                if first {
                    context?.move(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
                    first = false

                    // Draw at least a dot if there's just one point
                    if (data?.count ?? 0) == 1 {
                        context?.addLine(to: CGPoint(x: CGFloat(Double(x) + VALUE_LINE_WIDTH), y: CGFloat(y)))
                    }
                } else {
                    context?.addLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
                }
            }

            if !first {

                // Draw line and label if there's at least one point
                context?.strokePath()

                // Draw last point label
                if let sysBoldFont = sysBoldFont {
                    attributesDict = [
                        kCTFontAttributeName : sysBoldFont,
                        kCTForegroundColorAttributeName : VALUE_LABEL_COLOR.cgColor
                    ]
                }

                let label = String(format: "%7.2f", lastValue)
                let labelAttr = NSAttributedString(string: label, attributes: attributesDict as? [NSAttributedString.Key : Any])
                context?.textPosition = CGPoint(x: CGFloat(Double(size.width) - RIGHT_MARGIN), y: CGFloat(lastY))
                line = CTLineCreateWithAttributedString(labelAttr as CFAttributedString)
                if let context = context {
                    CTLineDraw(line!, context)
                }
            }
        }

        // Cleanup


    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

let LEFT_AXIS_MARGIN = 40.0
let BOTTOM_AXIS_MARGIN = 20.0
let RIGHT_MARGIN = 40.0

let CHART_BACKGROUND_COLOR = UIColor(red: 0.7176, green: 0.8431, blue: 0.9647, alpha: 1.0000)
let AXIS_LINE_COLOR = UIColor.darkGray
let AXIS_LABEL_COLOR = UIColor.darkGray
let INTEGER_LINE_COLOR = UIColor.darkGray
let INTEGER_LABEL_COLOR = UIColor.darkGray
let VALUE_LINE_COLOR = UIColor.blue
let VALUE_LABEL_COLOR = UIColor.blue
let THRESHOLD_LINE_COLOR = UIColor.red
let THRESHOLD_LABEL_COLOR = UIColor.red

let AXIS_LINE_WIDTH = 2.0
let INTEGER_LINE_WIDTH = 1.0
let VALUE_LINE_WIDTH = 2.0
let THRESHOLD_LINE_WIDTH = 1.0

let FONT_SIZE = 11.0
