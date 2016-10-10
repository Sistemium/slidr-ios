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
    
    static func path(_ radius: CGFloat) -> CGMutablePath {
        let path: CGMutablePath = CGMutablePath()
        path.addArc(center: CGPoint.zero, radius: radius, startAngle: 0.0, endAngle: CGFloat(2.0 * M_PI), clockwise: true)
        return path
    }
    
    func ripple(_ scale: CGFloat, duration: TimeInterval) {
        if let scene = scene {
            let currentRadius = radius
            let finalRadius = radius * scale
            let circleNode = RippleCircle(radius: radius, position: position)
            circleNode.strokeColor = strokeColor
            circleNode.fillColor = fillColor
            circleNode.position = position
            circleNode.zRotation = zRotation
            circleNode.lineWidth = lineWidth
            circleNode.isUserInteractionEnabled = false
            
            if let index = scene.children.index(of: self) {
                scene.insertChild(circleNode, at: index)
                
                let scaleAction = SKAction.customAction(withDuration: duration, actionBlock: { node, elapsedTime in
                    let circleNode = node as! RippleCircle
                    let fraction = elapsedTime / CGFloat(duration)
                    circleNode.radius = currentRadius! + (fraction * finalRadius)
                })
                
                let fadeAction = SKAction.fadeAlpha(to: 0, duration: duration)
                fadeAction.timingMode = SKActionTimingMode.easeOut
                
                let actionGroup = SKAction.group([scaleAction, fadeAction])
                
                circleNode.run(actionGroup, completion: {
                    circleNode.physicsBody = nil
                    circleNode.removeFromParent();
                })
            }
        }
    }
}


