//
//  Extensions.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 20/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import UIKit
import SpriteKit

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

extension CGSize{
    func reversed() -> CGSize {
        return CGSizeMake(height, width)
    }
}

extension SKScene{
    var dynamicChildren:[SKNode]{
        var dynamicChildren:[SKNode] = []
        for node in self.children{
            if node.physicsBody?.dynamic ?? false{
                dynamicChildren.append(node)
            }
        }
        return dynamicChildren
    }
}

private var startXAssocKey = 0
private var startYAssocKey = 0

extension UITouch {
    var startX: CGFloat! {
        get {
            return objc_getAssociatedObject(self, &startXAssocKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &startXAssocKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var startY: CGFloat! {
        get {
            return objc_getAssociatedObject(self, &startYAssocKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &startYAssocKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension Int{
    var deg2Rad : CGFloat
    {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}

