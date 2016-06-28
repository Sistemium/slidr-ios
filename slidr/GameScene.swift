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
    var timeSinceLastUpdate:CFTimeInterval?
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
    
    private var gameMode:GameMode = .Free
    
    var destroyedCount = 0
    
    var leftCount = 0
    
    var pushedCount = 0
    
    var freeModeTimer = GameSettings.freeModeTimer
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.lightGrayColor()
        self.physicsWorld.contactDelegate = self
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
            if block.color == UIColor.redColor(){
                if block.numberOfActions == nil || block.numberOfActions! > 0{
                    block.pushVector = CGVector(dx: -block.pushVector.dx, dy: -block.pushVector.dy)
                }
                if block.numberOfActions != nil{
                    block.numberOfActions! -= 1
                }
                return
            }
        }
        
        if node == toolbarNode.backButton{
            returnToPreviousScene()
        }
        
        for node in self.children{
            if let block = node as? Block{
                location = touches.first!.locationInNode(block)
                let region = SKRegion(size: CGSize(width: block.size.width + GameSettings.touchRegion, height: block.size.height + GameSettings.touchRegion))
                if region.containsPoint(location) && block.color == UIColor.redColor(){
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
        for node in self.children{
            if let block = node as? Block{
                if !block.pushed{
                    if self.intersectsNode(block){
                        block.pushed = true
                        pushedCount+=1
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
        if gameMode == .Free && self.freeModeTimer <= 0{
            let scene = GameResultScene()
            scene.size = GameSettings.playableAreaSize
            scene.scaleMode = .Fill
            scene.result = .Lose
            self.view!.presentScene(scene)
        }else if gameMode == .Level && level?.blocks.count == 0 && destroyedCount != 0 && pushedCount - unusedNodes() + 1 == destroyedCount && leftCount == 0{
            let scene = GameResultScene()
            scene.size = GameSettings.playableAreaSize
            scene.scaleMode = .Fill
            scene.result = .Win
            scene.finishedLevel = level
            self.view!.presentScene(scene)
        }
        else if gameMode == .Level && (level?.timeout<=0 || level?.blocks.count == 0 && self.children.count == unusedNodes() && leftCount != 0){
            let scene = GameResultScene()
            scene.size = GameSettings.playableAreaSize
            scene.scaleMode = .Fill
            scene.result = .Lose
            scene.finishedLevel = level
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
            var fRed : CGFloat = 0
            var fGreen : CGFloat = 0
            var fBlue : CGFloat = 0
            var fAlpha: CGFloat = 0
            block1.color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
            if fRed == 0 && fGreen == 0 && fBlue == 0{
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
            block2.color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
            if fRed == 0 && fGreen == 0 && fBlue == 0{
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
            if block1.pushVector.dx == -block2.pushVector.dx && block1.pushVector.dy == -block2.pushVector.dy{
                if block1.color == block2.color{
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
                    if block1.color == UIColor.redColor(){
                        freeModeTimer += GameSettings.redBlockReward
                    }
                    if block1.color == UIColor.blueColor(){
                        freeModeTimer += GameSettings.blueBlockReward
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
    
    func swipe(sender:UISwipeGestureRecognizer){
        if (sender.state == .Ended){
            var touchLocation = self.convertPointFromView(sender.locationInView(sender.view))
            let block = self.nodeAtPoint(touchLocation) as? Block
            if block?.color == UIColor.blueColor(){
                if block!.numberOfActions == nil || block!.numberOfActions! > 0{
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
                    let region = SKRegion(size: CGSize(width: block.size.width + GameSettings.touchRegion, height: block.size.height  * GameSettings.touchRegion))
                    if region.containsPoint(touchLocation) && block.color == UIColor.blueColor(){
                        candidatesToGesture[touchLocation.distance(block.anchorPoint)] = block
                    }
                }
            }
            if candidatesToGesture.keys.minElement() != nil{
                let chosen = candidatesToGesture[candidatesToGesture.keys.minElement()!]
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
    
    private func returnToPreviousScene(){
        let scene = previousScene!
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .Fill
        self.view!.presentScene(scene)
    }
    
}
