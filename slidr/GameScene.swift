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
    private var scoreNode : SKSpriteNode!{
        didSet{
            scoreNode.color = UIColor.darkGrayColor()
            scoreNode.position = CGPoint(x:destroyedLabel.position.x, y: destroyedLabel.position.y - destroyedLabel.frame.size.height / 3 )
            scoreNode.zPosition = 2.0
            scoreNode.size = CGSize(width: max(destroyedLabel.frame.size.width,leftLabel.frame.size.width) + 5 , height: destroyedLabel.frame.size.height + leftLabel.frame.size.height + 5)
            scoreNode.alpha = 0.5
        }
    }
    
    private var destroyedLabel : SKLabelNode!{
        didSet{
            destroyedLabel.text = "Destroyed: \(destroyedCount)"
            destroyedLabel.position = CGPoint(x: GameSettings.playableAreaSize.width - GameSettings.scoreNodeSize - 15, y: GameSettings.playableAreaSize.height - GameSettings.scoreNodeSize)
            destroyedLabel.fontSize = GameSettings.scoreNodeSize / 3
            destroyedLabel.zPosition = 3.0
            destroyedLabel.alpha = 0.5
            destroyedLabel.fontColor = .whiteColor()
        }
    }
    
    private var destroyedCount = 0{
        didSet{
            showScore()
            GameSettings.maxNumberOfBlocks -= 1
            if GameSettings.maxNumberOfBlocks < 3 {
                GameSettings.maxNumberOfBlocks = 3
            }
        }
    }
    
    private var leftLabel : SKLabelNode!{
        didSet{
            leftLabel.text = "Left: \(leftCount)"
            leftLabel.position = CGPoint(x: GameSettings.playableAreaSize.width - GameSettings.scoreNodeSize - 15, y: destroyedLabel.position.y - destroyedLabel.frame.height)
            leftLabel.fontSize = GameSettings.scoreNodeSize / 3
            leftLabel.zPosition = 3.0
            leftLabel.alpha = 0.5
            leftLabel.fontColor = .whiteColor()
        }
    }
    
    private var leftCount = 0{
        didSet{
            showScore()
            GameSettings.maxNumberOfBlocks += 1
        }
    }
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.rotated), name: UIDeviceOrientationDidChangeNotification, object: nil)
        showScore()
    }
    
    func showScore(){
        destroyedLabel?.removeFromParent()
        destroyedLabel = SKLabelNode(fontNamed:"Chalkduster")
        self.addChild(destroyedLabel)
        leftLabel?.removeFromParent()
        leftLabel = SKLabelNode(fontNamed:"Chalkduster")
        self.addChild(leftLabel)
        scoreNode?.removeFromParent()
        scoreNode = SKSpriteNode()
        self.addChild(scoreNode)
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
        if self.children.count - 3 < GameSettings.maxNumberOfBlocks{
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
                    leftCount += 1
                }
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
                    destroyedCount += 2
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
    
    override func didChangeSize(oldSize: CGSize) {
        GameSettings.playableAreaSize = UIScreen.mainScreen().bounds.size
        showScore()
    }
    
    func rotated(){
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
            showScore()
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)){
            showScore()
        }
        
    }
    
}
