//
//  Extensions.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 20/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

extension Double {
    func fixedFractionDigits(digits: Int) -> String {
        return String(format: "%.\(digits)f", self)
    }
}