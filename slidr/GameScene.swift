//
//  GameScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 03/05/16.
//  Copyright (c) 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

private enum GameMode{
    case Free,Level
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var timeSinceLastUpdate:CFTimeInterval?
    private var timeToNextBlockPush = GameSettings.pushBlockInterval
    private var toolbarNode : ToolbarNode!{
        didSet{
            self.addChild(toolbarNode)
            if gameMode == .Level{
                toolbarNode.scoreLabelEnabled = false
            }else{
                toolbarNode.scoreLabelEnabled = true
            }
        }
    }
    
    var previousScene:SKScene?
    
    var level: Level?{
        didSet{
            if (level != nil){
                gameMode = .Level
            }else{
                gameMode = .Free
            }
        }
    }
    
    private var gameMode:GameMode = .Free
    
    private var destroyedCount = 0{
        didSet{
            toolbarNode.scoreLabelText = "Score: \(destroyedCount - leftCount)"
        }
    }
    
    private var leftCount = 0{
        didSet{
            toolbarNode.scoreLabelText = "Score: \(destroyedCount - leftCount)"
        }
    }
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.lightGrayColor()
        self.physicsWorld.contactDelegate = self
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.rotated), name: UIDeviceOrientationDidChangeNotification, object: nil)
        toolbarNode  = ToolbarNode()
        destroyedCount = 0
        leftCount = 0
        var recognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipe))
        recognizer.direction = .Down
        self.view?.addGestureRecognizer(recognizer)
        recognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipe))
        recognizer.direction = .Left
        self.view?.addGestureRecognizer(recognizer)
        recognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipe))
        recognizer.direction = .Up
        self.view?.addGestureRecognizer(recognizer)
        recognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipe))
        recognizer.direction = .Right
        self.view?.addGestureRecognizer(recognizer)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first!.locationInNode(self)
        let node = self.nodeAtPoint(location)
        if let block = node as? Block{
            if block.color == UIColor.redColor(){
                block.pushVector = CGVector(dx: -block.pushVector.dx, dy: -block.pushVector.dy)
                return
            }
        }
        
        if node == toolbarNode.backButton{
            returnToPreviousScene()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if gameMode == .Level {
            if let oldTime = self.timeSinceLastUpdate{
                for block in level!.blocks{
                    block.preferedPushTime! -= currentTime - oldTime
                    if block.preferedPushTime < 0{
                        level?.blocks.removeAtIndex((level?.blocks.indexOf(block))!)
                        self.addChild(block)
                    }
                }
                level!.timeout! -= currentTime - oldTime
                toolbarNode.timerLabelText = level!.timeout!.fixedFractionDigits(1)
            }
        }
        else if self.children.count - 1 < GameSettings.maxNumberOfBlocks{
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
                if !block.pushed{
                    if self.intersectsNode(block){
                        block.pushed = true
                    }
                }
                block.physicsBody?.velocity = block.velocity
                if block.pushed && !self.intersectsNode(block){
                    block.removeFromParent()
                    leftCount+=1
                }
            }
        }
        checkResult()
        self.timeSinceLastUpdate = currentTime
    }
    
    private func checkResult(){
        if gameMode == .Level && level?.blocks.count == 0 && self.children.count == 1 && leftCount == 0{
            let scene = GameResultScene()
            scene.size = GameSettings.playableAreaSize
            scene.scaleMode = .AspectFit
            scene.result = .Win
            scene.finishedLevel = level
            self.view!.presentScene(scene)
        }
        else if gameMode == .Level && (level?.timeout<=0 || level?.blocks.count == 0 && self.children.count == 1 && leftCount != 0){
            let scene = GameResultScene()
            scene.size = GameSettings.playableAreaSize
            scene.scaleMode = .AspectFit
            scene.result = .Lose
            scene.finishedLevel = level
            self.view!.presentScene(scene)
        }
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
    
    func swipe(sender:UISwipeGestureRecognizer){
        if (sender.state == .Ended){
            let touchLocation = self.convertPointFromView(sender.locationInView(sender.view))
            let touchedNode = self.nodeAtPoint(touchLocation) as? Block
            if touchedNode?.color == UIColor.blueColor(){
                switch sender.direction {
                case UISwipeGestureRecognizerDirection.Up:
                    touchedNode?.pushVector = GameSettings.moveDirections[0]
                case UISwipeGestureRecognizerDirection.Down:
                    touchedNode?.pushVector = GameSettings.moveDirections[1]
                case UISwipeGestureRecognizerDirection.Right:
                    touchedNode?.pushVector = GameSettings.moveDirections[2]
                case UISwipeGestureRecognizerDirection.Left:
                    touchedNode?.pushVector = GameSettings.moveDirections[3]
                default:
                    break
                }
            }
        }
    }
    
    private func returnToPreviousScene(){
        let scene = previousScene!
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .AspectFit
        self.view!.presentScene(scene)
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
