//
//  Extensions.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 20/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import UIKit

extension Double {
    func fixedFractionDigits(digits: Int) -> String {
        return String(format: "%.\(digits)f", self)
    }
}

extension Float {
    func fixedFractionDigits(digits: Int) -> String {
        return String(format: "%.\(digits)f", self)
    }
}

extension CGFloat {
    func fixedFractionDigits(digits: Int) -> String {
        return String(format: "%.\(digits)f", self)
    }
}

extension CGPoint {
    func distance(point: CGPoint) -> CGFloat {
        return abs(CGFloat(hypotf(Float(point.x - x), Float(point.y - y))))
    }
}