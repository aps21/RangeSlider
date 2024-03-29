//
// Russvet
// Copyright © 2019 Heads and Hands. All rights reserved.
//

import QuartzCore
import UIKit

class RangeSliderTrackLayer: CALayer {
    weak var rangeSlider: RangeSlider?

    override func draw(in ctx: CGContext) {
        if let slider = rangeSlider {
            let cornerRadius = bounds.height * slider.curvaceousness / 2.0
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            ctx.addPath(path.cgPath)

            ctx.setFillColor(slider.trackTintColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()

            ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
            let lowerValuePosition = CGFloat(slider.positionForValue(value: slider.lowerValue))
            let upperValuePosition = CGFloat(slider.positionForValue(value: slider.upperValue))
            let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
            ctx.fill(rect)
        }
    }
}
