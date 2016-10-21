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
    func fixedFractionDigits(_ digits: Int) -> String {
        return String(format: "%.\(digits)f", self)
    }
}

extension Float {
    func fixedFractionDigits(_ digits: Int) -> String {
        return String(format: "%.\(digits)f", self)
    }
}

extension CGFloat {
    func fixedFractionDigits(_ digits: Int) -> String {
        return String(format: "%.\(digits)f", self)
    }
}

extension CGPoint {
    func distance(_ point: CGPoint) -> CGFloat {
        return abs(CGFloat(hypotf(Float(point.x - x), Float(point.y - y))))
    }
}

extension CGSize : Hashable{
    func reversed() -> CGSize {
        return CGSize(width: height, height: width)
    }
    
    public var hashValue: Int {
        return "\(width.rounded(),height.rounded())".hashValue
    }
    
    static func ==(x: CGSize, y: CGSize) -> Bool {
        return x.width == y.width && x.height == y.height
    }
}

extension SKScene{
    var dynamicChildren:[SKNode]{
        var dynamicChildren:[SKNode] = []
        for node in children{
            if node.physicsBody?.isDynamic ?? false{
                dynamicChildren.append(node)
            }
        }
        return dynamicChildren
    }
}

private var startXAssocKey = 0
private var startYAssocKey = 0

extension UITouch{
    var startX: CGFloat!{
        get {
            return objc_getAssociatedObject(self, &startXAssocKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &startXAssocKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var startY: CGFloat!{
        get {
            return objc_getAssociatedObject(self, &startYAssocKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &startYAssocKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension Int{
    var deg2Rad : CGFloat{
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}

extension Double{
    var deg2Rad : CGFloat{
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}

extension CGFloat{
    var deg2Rad : CGFloat{
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
    
    func toInt() -> Int? {
        if self > CGFloat(Int.min) && self < CGFloat(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}

extension SKAction {
    class func moveByY (_ deltaY: CGFloat, duration: TimeInterval) -> SKAction! {
        return SKAction.move(by: CGVector(dx: 0, dy: deltaY), duration: duration)
    }
}

extension CGPoint{
    var inverted:CGPoint{
        get{
            return CGPoint(x: -x, y: -y)
        }
    }
}

extension CGVector{
    var inverted:CGVector{
        get{
            return CGVector(dx: -dx, dy: -dy)
        }
    }
}

extension Range {
    public func random() -> Bound {
        let range = (self.upperBound as! Double) - (self.lowerBound as! Double)
        let randomValue = (Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX)) * range + (self.lowerBound as! Double)
        return randomValue as! Bound
    }
}

struct Dict2D<X:Hashable,Y:Hashable,V> {
    var values = [X:[Y:V]]()
    subscript (x:X, y:Y)->V? {
        get { return values[x]?[y] }
        set {
            if values[x] == nil {
                values[x] = [Y:V]()
            }
            values[x]![y] = newValue
        }
    }
}
