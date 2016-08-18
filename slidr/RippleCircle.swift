//
//  RippleCircle.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 07/07/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class RippleCircle: SKShapeNode {
    
    var radius: CGFloat! {
        didSet {
            path = RippleCircle.path(radius)
            physicsBody = SKPhysicsBody(circleOfRadius: radius)
            physicsBody!.collisionBitMask = 0
        }
    }
    
    init(radius: CGFloat, position: CGPoint) {
        self.radius = radius
        super.init()
        path = RippleCircle.path(radius)
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func path(radius: CGFloat) -> CGMutablePathRef {
        let path: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0.0, 0.0, radius, 0.0, CGFloat(2.0 * M_PI), true)
        return path
    }
    
    func ripple(scale: CGFloat, duration: NSTimeInterval) {
        if let scene = scene {
            let currentRadius = radius
            let finalRadius = radius * scale
            let circleNode = RippleCircle(radius: radius, position: position)
            circleNode.strokeColor = strokeColor
            circleNode.fillColor = fillColor
            circleNode.position = position
            circleNode.zRotation = zRotation
            circleNode.lineWidth = lineWidth
            circleNode.userInteractionEnabled = false
            
            if let index = scene.children.indexOf(self) {
                scene.insertChild(circleNode, atIndex: index)
                
                let scaleAction = SKAction.customActionWithDuration(duration, actionBlock: { node, elapsedTime in
                    let circleNode = node as! RippleCircle
                    let fraction = elapsedTime / CGFloat(duration)
                    circleNode.radius = currentRadius + (fraction * finalRadius)
                })
                
                let fadeAction = SKAction.fadeAlphaTo(0, duration: duration)
                fadeAction.timingMode = SKActionTimingMode.EaseOut
                
                let actionGroup = SKAction.group([scaleAction, fadeAction])
                
                circleNode.runAction(actionGroup, completion: {
                    circleNode.physicsBody = nil
                    circleNode.removeFromParent();
                })
            }
        }
    }
}


