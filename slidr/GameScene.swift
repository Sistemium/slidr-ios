//
//  GameScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 03/05/16.
//  Copyright (c) 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var timeSinceLastUpdate:CFTimeInterval?
    private var timeToNextBlockPush = 1.0
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first!.locationInNode(self)
        for node in self.children{
            if node.containsPoint(location){
                let block = node as! Block
                block.pushVector = CGVector(dx: -block.pushVector.dx, dy: -block.pushVector.dy)
                return
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if let oldTime = self.timeSinceLastUpdate{
            timeToNextBlockPush -= currentTime - oldTime
            if timeToNextBlockPush < 0 {
                timeToNextBlockPush += GameSettings.pushBlockInterval
                self.addChild(Block())
            }
        }
        for node in self.children{
            if let block = node as? Block{
                block.physicsBody?.velocity = block.pushVector
            }
        }
        self.timeSinceLastUpdate = currentTime
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if let block1 = contact.bodyA.node as? Block{
            if let block2 = contact.bodyB.node as? Block{
                if block1.pushVector.dx == -block2.pushVector.dx && block1.pushVector.dy == -block2.pushVector.dy{
                    block1.physicsBody = nil
                    block2.physicsBody = nil
                    let action = SKAction.fadeOutWithDuration(GameSettings.fadeOutDuration)
                    block1.runAction(action){
                        block1.removeFromParent()
                    }
                    block2.runAction(action){
                        block2.removeFromParent()
                    }
                }else{
                    let loseOfSpeedOfBlock1:CGFloat
                    if block1.pushVector.dx != 0{
                        loseOfSpeedOfBlock1 = block1.pushVector.dx - block1.physicsBody!.velocity.dx
                    }else{
                        loseOfSpeedOfBlock1 = block1.pushVector.dy - block1.physicsBody!.velocity.dy
                    }
                    let loseOfSpeedOfBlock2:CGFloat
                    if block2.pushVector.dx != 0{
                        loseOfSpeedOfBlock2 = block2.pushVector.dx - block2.physicsBody!.velocity.dx
                    }else{
                        loseOfSpeedOfBlock2 = block2.pushVector.dy - block2.physicsBody!.velocity.dy
                    }
                    if abs(loseOfSpeedOfBlock1) > abs(loseOfSpeedOfBlock2){
                        block2.pushVector = CGVector(dx: block1.pushVector.dx, dy: block1.pushVector.dy)
                        block1.pushVector = CGVector(dx: -block1.pushVector.dx, dy: -block1.pushVector.dy)
                    }else{
                        block1.pushVector = CGVector(dx: block2.pushVector.dx, dy: block2.pushVector.dy)
                        block2.pushVector = CGVector(dx: -block2.pushVector.dx, dy: -block2.pushVector.dy)            }
                }
            }
        }
    }
    
}
