//
//  GameScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 03/05/16.
//  Copyright (c) 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

enum GameMode{
    case Free,Level
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var timeSinceLastUpdate:CFTimeInterval?
    var startTime:CFTimeInterval?
    var timeToNextBlockPush = GameSettings.pushBlockInterval
    private var toolbarNode : ToolbarNode!{
        didSet{
            self.addChild(toolbarNode)
            if gameMode == .Level{
                toolbarNode.leftLabelText = level?.name ?? ""
            }else{
                toolbarNode.leftLabelText = "Free mode"
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
    
    var gameMode:GameMode = .Free
    
    var destroyedCount = 0
    
    var leftCount = 0
    
    var pushedCount = 0
    
    var isThereUnpushedBlocks = false
    
    var freeModeTimer = GameSettings.freeModeTimer
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.lightGrayColor()
        self.physicsWorld.contactDelegate = self
        toolbarNode?.removeFromParent()
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
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var location = touches.first!.locationInNode(self)
        let node = self.nodeAtPoint(location)
        if let block = node as? Block{
            if block.blockType == .bomb && block.physicsBody != nil{
                block.physicsBody = nil
                destroyedCount += 1
                let action = SKAction.fadeOutWithDuration(GameSettings.fadeOutDuration/3)
                block.runAction(action){
                    block.removeFromParent()
                }
                let ripple = RippleCircle(radius: 20, position: block.position)
                ripple.strokeColor = UIColor.yellowColor()
                ripple.lineWidth = 10
                self.addChild(ripple)
                ripple.ripple(20, duration: 1.0)
                ripple.removeFromParent()
                return
            }
            if block.numberOfActions == nil || block.numberOfActions! > 0{
                block.pushVector = CGVector(dx: -block.pushVector.dx, dy: -block.pushVector.dy)
            }
            if block.numberOfActions != nil{
                block.numberOfActions! -= 1
            }
            return
        }
        
        if node == toolbarNode.backButton{
            returnToPreviousScene()
        }
        
        for node in self.children{
            if let block = node as? Block{
                location = touches.first!.locationInNode(block)
                let region = SKRegion(size: CGSize(width: block.size.width + GameSettings.touchRegion, height: block.size.height + GameSettings.touchRegion))
                if region.containsPoint(location){
                    if block.blockType == .bomb && block.physicsBody != nil{
                        block.physicsBody = nil
                        destroyedCount += 1
                        let action = SKAction.fadeOutWithDuration(GameSettings.fadeOutDuration/3)
                        block.runAction(action){
                            block.removeFromParent()
                        }
                        let ripple = RippleCircle(radius: 20, position: block.position)
                        ripple.strokeColor = UIColor.yellowColor()
                        ripple.lineWidth = 10
                        self.addChild(ripple)
                        ripple.ripple(20, duration: 1.0)
                        ripple.removeFromParent()
                        return
                    }
                    if block.numberOfActions == nil || block.numberOfActions! > 0{
                        block.pushVector = CGVector(dx: -block.pushVector.dx, dy: -block.pushVector.dy)
                    }
                    if block.numberOfActions != nil{
                        block.numberOfActions! -= 1
                    }
                    return
                }
            }
        }
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        if gameMode == .Level{
            if let oldTime = self.timeSinceLastUpdate{
                level!.timeout! -= currentTime - oldTime
                toolbarNode.centerLabelText = level!.timeout!.fixedFractionDigits(1)
                if level?.timeout <= GameSettings.timeUntilWarning{
                    toolbarNode.centerLabelColor = UIColor.redColor()
                }else{
                    toolbarNode.centerLabelColor = UIColor.whiteColor()
                }
            }
        }else{
            if let oldTime = self.timeSinceLastUpdate{
                self.freeModeTimer -= currentTime - oldTime
                toolbarNode.centerLabelText = self.freeModeTimer.fixedFractionDigits(1)
                if self.freeModeTimer <= GameSettings.timeUntilWarning{
                    toolbarNode.centerLabelColor = UIColor.redColor()
                }else{
                    toolbarNode.centerLabelColor = UIColor.whiteColor()
                }
            }
        }
        if gameMode == .Level {
            if let oldTime = self.timeSinceLastUpdate{
                for block in level!.blocks{
                    block.preferedPushTime! -= currentTime - oldTime
                    if block.preferedPushTime < 0{
                        level?.blocks.removeAtIndex((level?.blocks.indexOf(block))!)
                        if GameSettings.playableAreaSize.width > GameSettings.playableAreaSize.height{
                            var t = block.position.x
                            block.position.x = (-block.position.y + 1)
                            block.position.y = t
                            t = block.size.height
                            block.size.height = block.size.width
                            block.size.width = t
                            block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
                            if block.blockType == .wall{
                                block.physicsBody!.dynamic = false
                            }
                            block.pushVector = CGVectorMake(-block.pushVector.dy, block.pushVector.dx)
                        }
                        block.position.x *= GameSettings.playableAreaSize.width
                        block.position.y *= GameSettings.playableAreaSize.height
                        self.addChild(block)
                    }
                }
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
        isThereUnpushedBlocks = false
        for node in self.children{
            if let block = node as? Block{
                if !block.pushed{
                    if self.intersectsNode(block){
                        block.pushed = true
                        pushedCount+=1
                    }else{
                        isThereUnpushedBlocks = true
                    }
                }
                block.physicsBody?.velocity = block.velocity
                if block.pushed && !self.intersectsNode(block){
                    block.removeFromParent()
                    leftCount+=1
                }
            }
        }
        if startTime == nil{
            startTime = currentTime
        }
        checkResult(currentTime)
        self.timeSinceLastUpdate = currentTime
    }
    
    private func checkResult(currentTime: CFTimeInterval){
        if gameMode == .Free && self.freeModeTimer <= 0{
            let scene = GameResultScene()
            scene.size = GameSettings.playableAreaSize
            scene.scaleMode = .Fill
            scene.result = .Lose
            scene.scoreTime = currentTime - startTime!
            scene.infoText = "Time's Up!"
            self.view!.presentScene(scene)
        }else if gameMode == .Level && level?.blocks.count == 0 && destroyedCount != 0 && leftCount == 0 && !isThereUnpushedBlocks && self.children.count - unusedNodes() == 0{
            let scene = GameResultScene()
            scene.size = GameSettings.playableAreaSize
            scene.scaleMode = .Fill
            scene.result = .Win
            scene.finishedLevel = level
            if NSUserDefaults.standardUserDefaults().valueForKey("completedLevels") as? Float ?? 0 < self.level!.priority{
                NSUserDefaults.standardUserDefaults().setValue(self.level!.priority, forKey: "completedLevels")
            }
            self.view!.presentScene(scene)
        }else if gameMode == .Level && leftCount != 0{
            let scene = GameResultScene()
            scene.size = GameSettings.playableAreaSize
            scene.scaleMode = .Fill
            scene.result = .Lose
            scene.finishedLevel = level
            scene.infoText = "Block left game area!"
            self.view!.presentScene(scene)
        }
        else if gameMode == .Level && level?.timeout<=0{
            let scene = GameResultScene()
            scene.size = GameSettings.playableAreaSize
            scene.scaleMode = .Fill
            scene.result = .Lose
            scene.finishedLevel = level
            scene.infoText = "Time's Up!"
            self.view!.presentScene(scene)
        }
        else if gameMode == .Level && level?.blocks.count == 0 && self.children.count - unusedNodes() == 0 && leftCount != 0{
            let scene = GameResultScene()
            scene.size = GameSettings.playableAreaSize
            scene.scaleMode = .Fill
            scene.result = .Lose
            scene.finishedLevel = level
            scene.infoText = "Block left game area!"
            self.view!.presentScene(scene)
        }
    }
    
    func unusedNodes()->Int{
        var count = 0
        for node in self.children{
            if let block = node as? Block{
                if !(block.physicsBody?.dynamic ?? true){
                    count+=1
                }
            }else{
                count+=1
            }
        }
        return count
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if let block1 = contact.bodyA.node as? Block, let block2 = contact.bodyB.node as? Block{
            if block1.blockType == .wall{
                if block1.rotation != 0{
                    if self.convertPoint(contact.contactPoint, toNode: block2).distance(block2.corners[0]) <= (abs(block2.pushVector.dy) + abs(block2.pushVector.dx))/1000{
                        if block2.pushVector.dy != 0{
                            block2.pushVector = CGVector(dx: -abs(block2.pushVector.dy), dy: 0)
                        }else{
                            block2.pushVector = CGVector(dx: 0, dy: -abs(block2.pushVector.dx))
                        }
                        return
                    }
                    if self.convertPoint(contact.contactPoint, toNode: block2).distance(block2.corners[1]) <= (abs(block2.pushVector.dy) + abs(block2.pushVector.dx))/1000{
                        if block2.pushVector.dy != 0{
                            block2.pushVector = CGVector(dx: -abs(block2.pushVector.dy), dy: 0)
                        }else{
                            block2.pushVector = CGVector(dx: 0, dy: abs(block2.pushVector.dx))
                        }
                        return
                    }
                    if self.convertPoint(contact.contactPoint, toNode: block2).distance(block2.corners[2]) <= (abs(block2.pushVector.dy) + abs(block2.pushVector.dx))/1000{
                        if block2.pushVector.dy != 0{
                            block2.pushVector = CGVector(dx: abs(block2.pushVector.dy), dy: 0)
                        }else{
                            block2.pushVector = CGVector(dx: 0, dy: abs(block2.pushVector.dx))
                        }
                        return
                    }
                    if self.convertPoint(contact.contactPoint, toNode: block2).distance(block2.corners[3]) <= (abs(block2.pushVector.dy) + abs(block2.pushVector.dx))/1000{
                        if block2.pushVector.dy != 0{
                            block2.pushVector = CGVector(dx: abs(block2.pushVector.dy), dy: 0)
                        }else{
                            block2.pushVector = CGVector(dx: 0, dy: -abs(block2.pushVector.dx))
                        }
                        return
                    }
                }
                block2.pushVector = CGVector(dx: -block2.pushVector.dx, dy: -block2.pushVector.dy)
                return
            }
            else if block2.blockType == .wall{
                if block2.rotation != 0{
                    if self.convertPoint(contact.contactPoint, toNode: block1).distance(block1.corners[0]) <= (abs(block1.pushVector.dy) + abs(block1.pushVector.dx))/1000{
                        if block1.pushVector.dy != 0{
                            block1.pushVector = CGVector(dx: -abs(block1.pushVector.dy), dy: 0)
                        }else{
                            block1.pushVector = CGVector(dx: 0, dy: -abs(block1.pushVector.dx))
                        }
                        return
                    }
                    if self.convertPoint(contact.contactPoint, toNode: block1).distance(block1.corners[1]) <= (abs(block1.pushVector.dy) + abs(block1.pushVector.dx))/1000{
                        if block1.pushVector.dy != 0{
                            block1.pushVector = CGVector(dx: -abs(block1.pushVector.dy), dy: 0)
                        }else{
                            block1.pushVector = CGVector(dx: 0, dy: abs(block1.pushVector.dx))
                        }
                        return
                    }
                    if self.convertPoint(contact.contactPoint, toNode: block1).distance(block1.corners[2]) <= (abs(block1.pushVector.dy) + abs(block1.pushVector.dx))/1000{
                        if block1.pushVector.dy != 0{
                            block1.pushVector = CGVector(dx: abs(block1.pushVector.dy), dy: 0)
                        }else{
                            block1.pushVector = CGVector(dx: 0, dy: abs(block1.pushVector.dx))
                        }
                        return
                    }
                    if self.convertPoint(contact.contactPoint, toNode: block1).distance(block1.corners[3]) <= (abs(block1.pushVector.dy) + abs(block1.pushVector.dx))/1000{
                        if block1.pushVector.dy != 0{
                            block1.pushVector = CGVector(dx: abs(block1.pushVector.dy), dy: 0)
                        }else{
                            block1.pushVector = CGVector(dx: 0, dy: -abs(block1.pushVector.dx))
                        }
                        return
                    }
                }
                block1.pushVector = CGVector(dx: -block1.pushVector.dx, dy: -block1.pushVector.dy)
                return
            }
            else if block1.pushVector.dx == -block2.pushVector.dx && block1.pushVector.dy == -block2.pushVector.dy{
                if block1.blockType == block2.blockType{
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
                    if block1.blockType == .standart{
                        freeModeTimer += GameSettings.redBlockReward * 2
                    }
                    if block1.blockType == .swipeable{
                        freeModeTimer += GameSettings.blueBlockReward * 2 
                    }
                }else{
                    if block1.blockType == .bomb{
                        block1.physicsBody = nil
                        let action = SKAction.fadeOutWithDuration(GameSettings.fadeOutDuration)
                        block1.runAction(action){
                            block1.removeFromParent()
                        }
                    }
                    if block2.blockType == .bomb{
                        block2.physicsBody = nil
                        let action = SKAction.fadeOutWithDuration(GameSettings.fadeOutDuration)
                        block2.runAction(action){
                            block2.removeFromParent()
                        }
                    }
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
        }else{
            if let block = contact.bodyA.node as? Block{
                block.physicsBody = nil
                destroyedCount += 1
                let action = SKAction.fadeOutWithDuration(GameSettings.fadeOutDuration)
                block.runAction(action){
                    block.removeFromParent()
                }
                if block.blockType == .standart{
                    freeModeTimer += GameSettings.redBlockReward
                }
                if block.blockType == .swipeable{
                    freeModeTimer += GameSettings.blueBlockReward
                }
            }else{
                if let block = contact.bodyB.node as? Block{
                    block.physicsBody = nil
                    destroyedCount += 1
                    let action = SKAction.fadeOutWithDuration(GameSettings.fadeOutDuration)
                    block.runAction(action){
                        block.removeFromParent()
                    }
                    if block.blockType == .standart{
                        freeModeTimer += GameSettings.redBlockReward
                    }
                    if block.blockType == .swipeable{
                        freeModeTimer += GameSettings.blueBlockReward
                    }
                }
            }
        }
    }
    
    func swipe(sender:UISwipeGestureRecognizer){
        if (sender.state == .Ended){
            var touchLocation = self.convertPointFromView(sender.locationInView(sender.view))
            let block = self.nodeAtPoint(touchLocation) as? Block
            if block != nil{
                if (block!.blockType == .standart || block!.blockType == .swipeable) && (block!.numberOfActions == nil || block!.numberOfActions! > 0){
                    if block?.blockType == .standart{
                        switch sender.direction {
                        case UISwipeGestureRecognizerDirection.Up:
                            if block?.pushVector.dy != 0 {
                                block?.pushVector = GameSettings.moveDirections[0]
                            }
                        case UISwipeGestureRecognizerDirection.Down:
                            if block?.pushVector.dy != 0 {
                                block?.pushVector = GameSettings.moveDirections[1]
                            }
                        case UISwipeGestureRecognizerDirection.Right:
                            if block?.pushVector.dx != 0 {
                                block?.pushVector = GameSettings.moveDirections[2]
                            }
                        case UISwipeGestureRecognizerDirection.Left:
                            if block?.pushVector.dx != 0 {
                                block?.pushVector = GameSettings.moveDirections[3]
                            }
                        default:
                            break
                        }
                    }else{
                        switch sender.direction {
                        case UISwipeGestureRecognizerDirection.Up:
                            block?.pushVector = GameSettings.moveDirections[0]
                        case UISwipeGestureRecognizerDirection.Down:
                            block?.pushVector = GameSettings.moveDirections[1]
                        case UISwipeGestureRecognizerDirection.Right:
                            block?.pushVector = GameSettings.moveDirections[2]
                        case UISwipeGestureRecognizerDirection.Left:
                            block?.pushVector = GameSettings.moveDirections[3]
                        default:
                            break
                        }
                    }
                }
                if block!.numberOfActions != nil{
                    block!.numberOfActions! -= 1
                }
                return
            }
            
            var candidatesToGesture:[CGFloat:Block] = [:]
            
            for node in self.children{
                if let block = node as? Block{
                    touchLocation = self.convertPointFromView(sender.locationInView(sender.view))
                    touchLocation = self.convertPoint(touchLocation, toNode: block)
                    if  block.blockType == .swipeable{
                        candidatesToGesture[touchLocation.distance(block.anchorPoint)] = block
                    }
                }
            }
            if candidatesToGesture.keys.minElement() != nil {
                let chosen = candidatesToGesture[candidatesToGesture.keys.minElement()!]
                touchLocation = self.convertPointFromView(sender.locationInView(sender.view))
                touchLocation = self.convertPoint(touchLocation, toNode: chosen!)
                let region = SKRegion(size: CGSize(width: chosen!.size.width + GameSettings.touchRegion, height: chosen!.size.height  * GameSettings.touchRegion))
                if region.containsPoint(touchLocation){
                    if chosen!.blockType == .standart{
                        switch sender.direction {
                        case UISwipeGestureRecognizerDirection.Up:
                            if chosen!.pushVector.dy != 0 {
                                chosen!.pushVector = GameSettings.moveDirections[0]
                            }
                        case UISwipeGestureRecognizerDirection.Down:
                            if chosen!.pushVector.dy != 0 {
                                chosen!.pushVector = GameSettings.moveDirections[1]
                            }
                        case UISwipeGestureRecognizerDirection.Right:
                            if chosen!.pushVector.dx != 0 {
                                chosen!.pushVector = GameSettings.moveDirections[2]
                            }
                        case UISwipeGestureRecognizerDirection.Left:
                            if chosen!.pushVector.dx != 0 {
                                chosen!.pushVector = GameSettings.moveDirections[3]
                            }
                        default:
                            break
                        }
                    }else{
                        switch sender.direction {
                        case UISwipeGestureRecognizerDirection.Up:
                            chosen!.pushVector = GameSettings.moveDirections[0]
                        case UISwipeGestureRecognizerDirection.Down:
                            chosen!.pushVector = GameSettings.moveDirections[1]
                        case UISwipeGestureRecognizerDirection.Right:
                            chosen!.pushVector = GameSettings.moveDirections[2]
                        case UISwipeGestureRecognizerDirection.Left:
                            chosen!.pushVector = GameSettings.moveDirections[3]
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    private func returnToPreviousScene(){
        let scene = previousScene!
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .Fill
        self.view!.presentScene(scene)
    }
    
    override func didChangeSize(oldSize: CGSize) {
        toolbarNode?.removeFromParent()
        toolbarNode  = ToolbarNode()
    }
}
