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
    private var timeToNextBlockPush = GameSettings.pushBlockInterval
    
    private var scoreLabel : SKLabelNode!{
        didSet{
            scoreLabel.text = "Score: \(destroyedCount)"
            scoreLabel.position = CGPoint(x: GameSettings.playableAreaSize.width - 60, y: GameSettings.playableAreaSize.height  - 30)
            scoreLabel.fontSize = GameSettings.scoreNodeSize
            scoreLabel.zPosition = 3.0
            scoreLabel.alpha = 0.5
            scoreLabel.fontColor = .whiteColor()
        }
    }
    
    private var destroyedCount = 0{
        didSet{
            showScore()
        }
    }
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.lightGrayColor()
        self.physicsWorld.contactDelegate = self
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.rotated), name: UIDeviceOrientationDidChangeNotification, object: nil)
        showScore()
    }
    
    func showScore(){
        scoreLabel?.removeFromParent()
        scoreLabel = SKLabelNode(fontNamed:"Chalkduster")
        self.addChild(scoreLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first!.locationInNode(self)
        for node in self.children{
            if node.containsPoint(location){
                if let block = node as? Block{
                    block.pushVector = CGVector(dx: -block.pushVector.dx, dy: -block.pushVector.dy)
                    return
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if self.children.count - 2 < GameSettings.maxNumberOfBlocks{
            if let oldTime = self.timeSinceLastUpdate{
                timeToNextBlockPush -= currentTime - oldTime
                if timeToNextBlockPush < 0 {
                    let block = Block()
                    let testNode = SKSpriteNode()
                    testNode.size = CGSize(width: block.frame.width * 2, height:block.frame.height * 2)
                    testNode.position = block.position
                    var testPassed = true
                    for node in self.children{
                        if let comparableNode = node as? Block{
                            if testNode.intersectsNode(comparableNode){
                                testPassed = false
                                break
                            }
                        }
                    }
                    if testPassed{
                        timeToNextBlockPush += GameSettings.pushBlockInterval
                        self.addChild(block)
                    }
                }
                
            }
        }
        for node in self.children{
            if let block = node as? Block{
                block.physicsBody?.velocity = block.velocity
                if !self.intersectsNode(block){
                    block.removeFromParent()
                }
            }
        }
        self.timeSinceLastUpdate = currentTime
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if let block1 = contact.bodyA.node as? Block{
            if let block2 = contact.bodyB.node as? Block{
                if block1.pushVector.dx == -block2.pushVector.dx && block1.pushVector.dy == -block2.pushVector.dy{
                    if block1.color == block2.color{
                        block1.physicsBody = nil
                        block2.physicsBody = nil
                        destroyedCount += 1
                        let action = SKAction.fadeOutWithDuration(GameSettings.fadeOutDuration)
                        block1.runAction(action){
                            block1.removeFromParent()
                        }
                        block2.runAction(action){
                            block2.removeFromParent()
                        }
                    }else{
                        block1.pushVector = CGVector(dx: -block1.pushVector.dx, dy: -block1.pushVector.dy)
                        block2.pushVector = CGVector(dx: -block2.pushVector.dx, dy: -block2.pushVector.dy)
                    }
                }else{
                    if block1.pushVector.dx == block2.pushVector.dx && block1.pushVector.dy == block2.pushVector.dy{
                        if abs(block1.velocity.dx + block1.velocity.dy) > abs(block2.velocity.dx + block2.velocity.dy){
                            block1.pushVector = CGVector(dx: -block1.pushVector.dx, dy: -block1.pushVector.dy)
                        }else{
                            block2.pushVector = CGVector(dx: -block2.pushVector.dx, dy: -block2.pushVector.dy)
                        }
                    }
                    else{
                        let loseOfSpeedOfBlock1:CGFloat
                        if block1.pushVector.dx != 0{
                            loseOfSpeedOfBlock1 = block1.velocity.dx / block1.physicsBody!.velocity.dx
                        }else{
                            loseOfSpeedOfBlock1 = block1.velocity.dy / block1.physicsBody!.velocity.dy
                        }
                        let loseOfSpeedOfBlock2:CGFloat
                        if block2.pushVector.dx != 0{
                            loseOfSpeedOfBlock2 = block2.velocity.dx / block2.physicsBody!.velocity.dx
                        }else{
                            loseOfSpeedOfBlock2 = block2.velocity.dy / block2.physicsBody!.velocity.dy
                        }
                        if abs(loseOfSpeedOfBlock1) > abs(loseOfSpeedOfBlock2){
                            block2.pushVector = CGVector(dx: block1.pushVector.dx, dy: block1.pushVector.dy)
                            block1.pushVector = CGVector(dx: -block1.pushVector.dx, dy: -block1.pushVector.dy)
                        }else{
                            block1.pushVector = CGVector(dx: block2.pushVector.dx, dy: block2.pushVector.dy)
                            block2.pushVector = CGVector(dx: -block2.pushVector.dx, dy: -block2.pushVector.dy)
                        }
                    }
                }
            }
        }
    }
    
//    override func didChangeSize(oldSize: CGSize) {
//        GameSettings.playableAreaSize = UIScreen.mainScreen().bounds.size
//        showScore()
//    }
//    
//    func rotated(){
//        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
//            showScore()
//        }
//        
//        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)){
//            showScore()
//        }
//        
//    }
    
}
