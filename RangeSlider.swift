//
// Russvet
// Copyright © 2019 Heads and Hands. All rights reserved.
//

import QuartzCore
import UIKit

class RangeSlider: UIControl {
    private let trackLayer = RangeSliderTrackLayer()
    private let lowerThumbLayer = RangeSliderThumbLayer()
    private let upperThumbLayer = RangeSliderThumbLayer()

    var initialDigitsRange = 0.0 ... 1.0 {
        didSet {
            if lowerValue != initialDigitsRange.lowerBound || upperValue != initialDigitsRange.upperBound {
                lowerValue = initialDigitsRange.lowerBound
                upperValue = initialDigitsRange.upperBound
                updateLayerFrames()
            }
        }
    }

    private var previousLocation = CGPoint()

    let trackTintColor = Asset.veryLightBlue.color
    let trackHighlightTintColor = Asset.waterBlue.color
    let thumbTintColor = Asset.white.color

    let trackHeight: CGFloat = 2
    let curvaceousness: CGFloat = 1.0

    var lowerValue = 0.0
    var upperValue = 1.0

    var lowerChangeCallback: ((Double) -> Void)?
    var upperChangeCallback: ((Double) -> Void)?

    private var thumbWidth: CGFloat {
        CGFloat(bounds.height)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrames()
    }

    override func beginTracking(_ touch: UITouch, with _: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)

        if lowerThumbLayer.frame.contains(previousLocation) {
            lowerThumbLayer.isHighlighted = true
        } else if upperThumbLayer.frame.contains(previousLocation) {
            upperThumbLayer.isHighlighted = true
        }

        return lowerThumbLayer.isHighlighted || upperThumbLayer.isHighlighted || upperValue == lowerValue
    }

    override func continueTracking(_ touch: UITouch, with _: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (initialDigitsRange.upperBound - initialDigitsRange.lowerBound) * deltaLocation / Double(bounds.width - thumbWidth)

        previousLocation = location

        if upperValue == lowerValue {
            if deltaLocation > 0 {
                lowerThumbLayer.isHighlighted = false
                upperThumbLayer.isHighlighted = true
            } else {
                lowerThumbLayer.isHighlighted = true
                upperThumbLayer.isHighlighted = false
            }
        }

        if lowerThumbLayer.isHighlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(value: lowerValue, toLowerValue: initialDigitsRange.lowerBound, upperValue: upperValue)
            lowerChangeCallback?(lowerValue)
        } else if upperThumbLayer.isHighlighted {
            upperValue += deltaValue
            upperValue = boundValue(value: upperValue, toLowerValue: lowerValue, upperValue: initialDigitsRange.upperBound)
            upperChangeCallback?(upperValue)
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        updateLayerFrames()

        CATransaction.commit()

        sendActions(for: .valueChanged)

        return true
    }

    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        endTracking()
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        endTracking()
    }

    private func endTracking() {
        lowerThumbLayer.isHighlighted = false
        upperThumbLayer.isHighlighted = false

        updateLayerFrames()
    }

    override func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        false
    }

    private func setup() {
        trackLayer.rangeSlider = self
        layer.addSublayer(trackLayer)

        lowerThumbLayer.rangeSlider = self
        lowerThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerThumbLayer)

        upperThumbLayer.rangeSlider = self
        upperThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperThumbLayer)
    }

    private func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        min(max(value, lowerValue), upperValue)
    }

    func updateLayerFrames() {
        trackLayer.frame = bounds.insetBy(dx: 2.0, dy: (bounds.height - trackHeight) / 2)
        trackLayer.setNeedsDisplay()

        let lowerThumbCenter = CGFloat(positionForValue(value: lowerValue))

        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: 0.0, width: thumbWidth, height: thumbWidth)
        lowerThumbLayer.setNeedsDisplay()

        let upperThumbCenter = CGFloat(positionForValue(value: upperValue))
        upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2.0, y: 0.0, width: thumbWidth, height: thumbWidth)
        upperThumbLayer.setNeedsDisplay()
    }

    func positionForValue(value: Double) -> Double {
        Double(bounds.width - thumbWidth) * (value - initialDigitsRange.lowerBound) /
            (initialDigitsRange.upperBound - initialDigitsRange.lowerBound) + Double(thumbWidth / 2.0)
    }
}
