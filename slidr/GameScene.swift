//
//  GameScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 03/05/16.
//  Copyright (c) 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

enum GameMode{
    case Free,Level,Menu
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var timeSinceLastUpdate:CFTimeInterval?
    
    var startTime:CFTimeInterval?
    
    var timeToNextBlockPush = GameSettings.pushBlockInterval
    
    private var toolbarNode : ToolbarNode!{
        willSet{
            toolbarNode?.removeFromParent()
        }
        didSet{
            switch gameMode{
            case .Level:
                addChild(toolbarNode)
                toolbarNode.leftLabelText = level?.name ?? ""
                toolbarNode.rightButton = toolbarNode.backButton
            case .Free:
                addChild(toolbarNode)
                toolbarNode.leftLabelText = "Free mode"
                toolbarNode.rightButton = toolbarNode.backButton
            default:
                break
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
    
    var blockLeftGameArea = false
    
    var isThereUnpushedBlocks = false
    
    var freeModeTimer = GameSettings.freeModeTimer
    
    private func checkResult(currentTime: CFTimeInterval){
        switch gameMode{
        case .Level:
            if blockLeftGameArea {
                presentResultScene(.Lose, infoText: "Block left game area!")
            }
            else if level?.timeout<=0 {
                presentResultScene(.Lose, infoText: "Time's Up!")
            }
            else if !isThereUnpushedBlocks && dynamicChildren.count == 0{
                presentResultScene(.Win, infoText: "")
            }
        case .Free:
            if freeModeTimer <= 0 {
                presentResultScene(.Lose, infoText: "Time's Up!",score: currentTime - startTime!)
            }
        default:
            break
        }
    }
    
    private func presentResultScene(result:Result,infoText:String,score:CFTimeInterval? = nil){
        let scene = GameResultScene()
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .Fill
        scene.result = result
        scene.finishedLevel = level ?? nil
        scene.infoText = infoText
        if let time = score{
            scene.scoreTime = time
        }
        view!.presentScene(scene)
    }
    
    private func destroyBlock(block:Block,withTime time:Double, withReward reward:Double? = nil){
        if reward != nil && gameMode == .Free{
            let score = SKLabelNode(fontNamed:"Chalkduster")
            addChild(score)
            score.position = block.position
            score.fontSize = GameSettings.toolbarHeight / 1.5
            score.zPosition = 1.5
            score.fontColor = UIColor.greenColor()
            score.text = "+" + reward!.description
            let group = SKAction.group([SKAction.fadeOutWithDuration(time * 2),SKAction.moveByY(200, duration: time * 2)])
            score.runAction(group){
                score.removeFromParent()
            }
            freeModeTimer += reward!
        }
        block.runAction(SKAction.fadeOutWithDuration(time)){
            block.removeFromParent()
        }
    }
    
    private func repulseBlock(block:Block,fromWall wall:Block,withContactPoint point:CGPoint){
        if wall.rotation != 0{
            if convertPoint(point, toNode: block).distance(block.corners[0]) <= (abs(block.pushVector.dy) + abs(block.pushVector.dx))/1000{
                if block.pushVector.dy != 0{
                    block.pushVector = CGVector(dx: -abs(block.pushVector.dy), dy: 0)
                }else{
                    block.pushVector = CGVector(dx: 0, dy: -abs(block.pushVector.dx))
                }
                return
            }
            if convertPoint(point, toNode: block).distance(block.corners[1]) <= (abs(block.pushVector.dy) + abs(block.pushVector.dx))/1000{
                if block.pushVector.dy != 0{
                    block.pushVector = CGVector(dx: -abs(block.pushVector.dy), dy: 0)
                }else{
                    block.pushVector = CGVector(dx: 0, dy: abs(block.pushVector.dx))
                }
                return
            }
            if convertPoint(point, toNode: block).distance(block.corners[2]) <= (abs(block.pushVector.dy) + abs(block.pushVector.dx))/1000{
                if block.pushVector.dy != 0{
                    block.pushVector = CGVector(dx: abs(block.pushVector.dy), dy: 0)
                }else{
                    block.pushVector = CGVector(dx: 0, dy: abs(block.pushVector.dx))
                }
                return
            }
            if convertPoint(point, toNode: block).distance(block.corners[3]) <= (abs(block.pushVector.dy) + abs(block.pushVector.dx))/1000{
                if block.pushVector.dy != 0{
                    block.pushVector = CGVector(dx: abs(block.pushVector.dy), dy: 0)
                }else{
                    block.pushVector = CGVector(dx: 0, dy: -abs(block.pushVector.dx))
                }
                return
            }
        }
        block.pushVector = CGVector(dx: -block.pushVector.dx, dy: -block.pushVector.dy)
    }
    
    func nullVelocityCollisionOccuredWith(block1:Block,block2:Block) -> Bool{
        //dangerous fix for caterpillar bug, if somthing went wrong witch block colision consider that it is the reason
        var loseOfSpeedOfBlock1:CGFloat
        if block1.pushVector.dx != 0{
            loseOfSpeedOfBlock1 = block1.velocity.dx / block1.physicsBody!.velocity.dx
        }else{
            loseOfSpeedOfBlock1 = block1.velocity.dy / block1.physicsBody!.velocity.dy
        }
        var loseOfSpeedOfBlock2:CGFloat
        if block2.pushVector.dx != 0{
            loseOfSpeedOfBlock2 = block2.velocity.dx / block2.physicsBody!.velocity.dx
        }else{
            loseOfSpeedOfBlock2 = block2.velocity.dy / block2.physicsBody!.velocity.dy
        }
        if loseOfSpeedOfBlock1.isNaN {
            loseOfSpeedOfBlock1 = 1
        }
        if loseOfSpeedOfBlock2.isNaN {
            loseOfSpeedOfBlock2 = 1
        }
        if Int(loseOfSpeedOfBlock1) == 1 && Int(loseOfSpeedOfBlock2) == 1{
            return true
        }
        return false
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.node == nil || contact.bodyB.node == nil {
            return
        }
        if let block1 = contact.bodyA.node as? Block, let block2 = contact.bodyB.node as? Block{
            if block1.type == .wall{
                if nullVelocityCollisionOccuredWith(block1,block2: block2) {
                    return
                }
                repulseBlock(block2,fromWall:block1,withContactPoint: contact.contactPoint)
                return
            }
            else if block2.type == .wall{
                if nullVelocityCollisionOccuredWith(block1,block2: block2) {
                    return
                }
                repulseBlock(block1, fromWall: block2, withContactPoint: contact.contactPoint)
                return
            }
            else if block1.pushVector.dx == -block2.pushVector.dx && block1.pushVector.dy == -block2.pushVector.dy{
                if nullVelocityCollisionOccuredWith(block1,block2: block2) {
                    return
                }
                if block1.type == block2.type {
                    block1.physicsBody = nil
                    block2.physicsBody = nil
                    if block1.type == .standart{
                        destroyBlock(block1,withTime: GameSettings.blockFadeoutTime, withReward:GameSettings.redBlockReward)
                        destroyBlock(block2,withTime: GameSettings.blockFadeoutTime, withReward:GameSettings.redBlockReward)
                    }
                    if block1.type == .swipeable{
                        destroyBlock(block1,withTime: GameSettings.blockFadeoutTime, withReward:GameSettings.blueBlockReward)
                        destroyBlock(block2,withTime: GameSettings.blockFadeoutTime, withReward:GameSettings.blueBlockReward)
                    }
                    if block1.type == .bomb{
                        destroyBlock(block1,withTime: GameSettings.blockFadeoutTime)
                        destroyBlock(block2,withTime: GameSettings.blockFadeoutTime)
                    }
                }else{
                    block1.pushVector = CGVector(dx: -block1.pushVector.dx, dy: -block1.pushVector.dy)
                    block2.pushVector = CGVector(dx: -block2.pushVector.dx, dy: -block2.pushVector.dy)
                    if block1.type == .bomb{
                        block1.physicsBody = nil
                        destroyBlock(block1,withTime: GameSettings.blockFadeoutTime)
                    }
                    if block2.type == .bomb{
                        block2.physicsBody = nil
                        destroyBlock(block2,withTime: GameSettings.blockFadeoutTime)
                    }
                }
            }else{
                if block1.pushVector.dx == block2.pushVector.dx && block1.pushVector.dy == block2.pushVector.dy{
                    if abs(block1.velocity.dx + block1.velocity.dy) > abs(block2.velocity.dx + block2.velocity.dy){
                        block1.pushVector = CGVector(dx: -block1.pushVector.dx, dy: -block1.pushVector.dy)
                    }else{
                        block2.pushVector = CGVector(dx: -block2.pushVector.dx, dy: -block2.pushVector.dy)
                    }
                    if block1.type == .bomb{
                        block1.physicsBody = nil
                        destroyBlock(block1,withTime: GameSettings.blockFadeoutTime)
                    }
                    if block2.type == .bomb{
                        block2.physicsBody = nil
                        destroyBlock(block2,withTime: GameSettings.blockFadeoutTime)
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
                    if block1.type == .bomb{
                        block1.physicsBody = nil
                        destroyBlock(block1,withTime: GameSettings.blockFadeoutTime)
                    }
                    if block2.type == .bomb{
                        block2.physicsBody = nil
                        destroyBlock(block2,withTime: GameSettings.blockFadeoutTime)
                    }
                }
            }
        }else{
            if let block = contact.bodyA.node as? Block ?? contact.bodyB.node as? Block{
                if block.type == .bomb && block.physicsBody != nil{
                    block.physicsBody = nil
                    destroyBlock(block,withTime: 0)
                    let ripple = RippleCircle(radius: GameSettings.rippleRadius, position: block.position)
                    ripple.strokeColor = UIColor.yellowColor()
                    ripple.lineWidth = 10
                    addChild(ripple)
                    ripple.ripple(GameSettings.rippleRadius, duration: 1.0)
                    ripple.removeFromParent()
                    return
                }else{
                    block.physicsBody = nil
                    var reward:Double? = nil
                    if block.type == .standart{
                        freeModeTimer += GameSettings.redBlockReward
                        reward = GameSettings.redBlockReward
                    }
                    if block.type == .swipeable{
                        freeModeTimer += GameSettings.blueBlockReward
                        reward = GameSettings.blueBlockReward
                    }
                    destroyBlock(block,withTime: GameSettings.blockFadeoutTime, withReward:reward)
                }
            }
        }
    }
    
    private func returnToPreviousScene(){
        let scene = previousScene!
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .Fill
        view!.presentScene(scene)
    }
    
    // MARK: User interactions
    
    func nodeInPoint(p: CGPoint) -> SKNode? { //node at point is not very trustable
        return nodesAtPoint(p).filter{return $0.zPosition == 1.0 || $0.zPosition == 33.0}.sort{return $0.zPosition < $1.zPosition}.last
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for toch in touches{
            let location = toch.locationInNode(self)
            toch.startX = location.x
            toch.startY = location.y
        }
    }
    
    private func determinateSwipeDirection(dx:CGFloat,_ dy:CGFloat) -> UISwipeGestureRecognizerDirection?{
        if abs(dx) > abs(dy) {
            if dx < 0{
                return .Left
            }
            if dx > 0{
                return .Right
            }
        }
        if abs(dx) < abs(dy) {
            if dy < 0{
                return .Down
            }
            if dy > 0{
                return .Up
            }
        }
        return nil
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        tochesCycle: for toch in touches{
            var location = toch.locationInNode(self)
            var dx = location.x - toch.startX
            var dy = location.y - toch.startY
            let magnitude = sqrt(dx*dx+dy*dy)
            dx = dx / magnitude
            dy = dy / magnitude
            let direction = determinateSwipeDirection(dx, dy)
            if direction != nil{
                swipe(CGPoint(x: toch.startX,y: toch.startY), direction: direction!)
                continue
            }
            
            let node = nodeInPoint(location)
            if let block = node as? Block{
                if block.type == .bomb && block.physicsBody != nil{
                    block.physicsBody = nil
                    destroyBlock(block,withTime: 0)
                    let ripple = RippleCircle(radius: 20, position: block.position)
                    ripple.strokeColor = UIColor.yellowColor()
                    ripple.lineWidth = 10
                    addChild(ripple)
                    ripple.ripple(20, duration: 1.0)
                    ripple.removeFromParent()
                    continue
                }
                if block.physicsBody != nil && (block.numberOfActions == nil || block.numberOfActions! > 0){
                    block.pushVector = CGVector(dx: -block.pushVector.dx, dy: -block.pushVector.dy)
                }
                if block.numberOfActions != nil{
                    block.numberOfActions! -= 1
                }
                continue
            }
            
            if node == toolbarNode.backButton{
                returnToPreviousScene()
            }
            
            for node in children{
                if let block = node as? Block{
                    location = touches.first!.locationInNode(block)
                    let region = SKRegion(size: CGSize(width: block.size.width + GameSettings.touchRegion, height: block.size.height + GameSettings.touchRegion))
                    if region.containsPoint(location){
                        if block.type == .bomb && block.physicsBody != nil{
                            block.physicsBody = nil
                            destroyBlock(block,withTime: 0)
                            let ripple = RippleCircle(radius: 20, position: block.position)
                            ripple.strokeColor = UIColor.yellowColor()
                            ripple.lineWidth = 10
                            addChild(ripple)
                            ripple.ripple(20, duration: 1.0)
                            ripple.removeFromParent()
                            continue tochesCycle
                        }
                        if block.physicsBody != nil && (block.numberOfActions == nil || block.numberOfActions! > 0){
                            block.pushVector = CGVector(dx: -block.pushVector.dx, dy: -block.pushVector.dy)
                        }
                        if block.numberOfActions != nil{
                            block.numberOfActions! -= 1
                        }
                        continue tochesCycle
                    }
                }
            }
        }
    }
    
    func swipe(touchLocation:CGPoint, direction:UISwipeGestureRecognizerDirection){
        let block = nodeInPoint(touchLocation) as? Block
        if block != nil && block?.physicsBody != nil{
            if (block!.type == .standart || block!.type == .swipeable) && (block!.numberOfActions == nil || block!.numberOfActions! > 0){
                if block?.type == .standart{
                    switch direction {
                    case UISwipeGestureRecognizerDirection.Up:
                        if block?.pushVector.dy != 0 {
                            block?.boost = GameSettings.boostValue
                            block?.pushVector = GameSettings.moveDirections[0]
                        }
                    case UISwipeGestureRecognizerDirection.Down:
                        if block?.pushVector.dy != 0 {
                            block?.boost = GameSettings.boostValue
                            block?.pushVector = GameSettings.moveDirections[1]
                        }
                    case UISwipeGestureRecognizerDirection.Right:
                        if block?.pushVector.dx != 0 {
                            block?.boost = GameSettings.boostValue
                            block?.pushVector = GameSettings.moveDirections[2]
                        }
                    case UISwipeGestureRecognizerDirection.Left:
                        if block?.pushVector.dx != 0 {
                            block?.boost = GameSettings.boostValue
                            block?.pushVector = GameSettings.moveDirections[3]
                        }
                    default:
                        break
                    }
                }else{
                    switch direction {
                    case UISwipeGestureRecognizerDirection.Up:
                        block?.boost = GameSettings.boostValue
                        block?.pushVector = GameSettings.moveDirections[0]
                    case UISwipeGestureRecognizerDirection.Down:
                        block?.boost = GameSettings.boostValue
                        block?.pushVector = GameSettings.moveDirections[1]
                    case UISwipeGestureRecognizerDirection.Right:
                        block?.boost = GameSettings.boostValue
                        block?.pushVector = GameSettings.moveDirections[2]
                    case UISwipeGestureRecognizerDirection.Left:
                        block?.boost = GameSettings.boostValue
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
        
        for node in children{
            if let block = node as? Block{
                let touchLocation = convertPoint(touchLocation, toNode: block)
                if block.type == .swipeable || block.type == .standart{
                    candidatesToGesture[touchLocation.distance(block.anchorPoint)] = block
                }
            }
        }
        if candidatesToGesture.keys.minElement() != nil {
            let chosen = candidatesToGesture[candidatesToGesture.keys.minElement()!]
            let touchLocation = convertPoint(touchLocation, toNode: chosen!)
            let region = SKRegion(size: CGSize(width: chosen!.size.width + GameSettings.touchRegion, height: chosen!.size.height  * GameSettings.touchRegion))
            if region.containsPoint(touchLocation){
                if chosen!.type == .standart{
                    switch direction {
                    case UISwipeGestureRecognizerDirection.Up:
                        if chosen!.pushVector.dy != 0 {
                            chosen!.boost = GameSettings.boostValue
                            chosen!.pushVector = GameSettings.moveDirections[0]
                        }
                    case UISwipeGestureRecognizerDirection.Down:
                        if chosen!.pushVector.dy != 0 {
                            chosen!.boost = GameSettings.boostValue
                            chosen!.pushVector = GameSettings.moveDirections[1]
                        }
                    case UISwipeGestureRecognizerDirection.Right:
                        if chosen!.pushVector.dx != 0 {
                            chosen!.boost = GameSettings.boostValue
                            chosen!.pushVector = GameSettings.moveDirections[2]
                        }
                    case UISwipeGestureRecognizerDirection.Left:
                        if chosen!.pushVector.dx != 0 {
                            chosen!.boost = GameSettings.boostValue
                            chosen!.pushVector = GameSettings.moveDirections[3]
                        }
                    default:
                        break
                    }
                }else{
                    switch direction {
                    case UISwipeGestureRecognizerDirection.Up:
                        chosen!.boost = GameSettings.boostValue
                        chosen!.pushVector = GameSettings.moveDirections[0]
                    case UISwipeGestureRecognizerDirection.Down:
                        chosen!.boost = GameSettings.boostValue
                        chosen!.pushVector = GameSettings.moveDirections[1]
                    case UISwipeGestureRecognizerDirection.Right:
                        chosen!.boost = GameSettings.boostValue
                        chosen!.pushVector = GameSettings.moveDirections[2]
                    case UISwipeGestureRecognizerDirection.Left:
                        chosen!.boost = GameSettings.boostValue
                        chosen!.pushVector = GameSettings.moveDirections[3]
                    default:
                        break
                    }
                }
            }
        }
    }
    
    // MARK: Lifecycle
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.lightGrayColor()
        physicsWorld.contactDelegate = self
        toolbarNode  = ToolbarNode()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.rotationEnded), name: "RotationEnded", object: nil)
    }
    
    func rotationEnded(){
        for child in children{
            if let block = child as? Block{
                block.hidden = false
                block.movementEnabled = true
            }
        }
    }
    
    override func didChangeSize(oldSize: CGSize) {
        toolbarNode  = ToolbarNode()
        for child in children{
            if let block = child as? Block{
                block.hidden = true
                block.movementEnabled = false
                block.position.x /= oldSize.width
                block.position.y /= oldSize.height
                switch (UIDevice.currentDevice().orientation,GameSettings.lastKnownOrientation) {
                case (.LandscapeLeft, .Portrait), (.PortraitUpsideDown, .LandscapeLeft), (.LandscapeRight, .PortraitUpsideDown), (.Portrait, .LandscapeRight):
                    block.switchOrientationToLeft()
                case (.LandscapeRight, .Portrait), (.PortraitUpsideDown, .LandscapeRight), (.LandscapeLeft, .PortraitUpsideDown), (.Portrait, .LandscapeLeft):
                    block.switchOrientationToRight()
                case (.PortraitUpsideDown, .Portrait), (.Portrait, .PortraitUpsideDown), (.LandscapeLeft, .LandscapeRight), (.LandscapeRight, .LandscapeLeft):
                    block.switchOrientationToRight()
                    block.switchOrientationToRight()
                default:
                    break
                }
                block.position.x *= GameSettings.playableAreaSize.width
                block.position.y *= GameSettings.playableAreaSize.height
            }
        }
        GameSettings.lastKnownOrientation = UIDevice.currentDevice().orientation
    }
    
    override func update(currentTime: CFTimeInterval) {
        if gameMode == .Level{
            if let oldTime = timeSinceLastUpdate{
                level!.timeout! -= currentTime - oldTime
                toolbarNode.centerLabelText = level!.timeout!.fixedFractionDigits(1)
                if level?.timeout <= GameSettings.timeUntilWarning{
                    toolbarNode.centerLabelColor = UIColor.redColor()
                }else{
                    toolbarNode.centerLabelColor = UIColor.whiteColor()
                }
            }
        }else{
            if let oldTime = timeSinceLastUpdate{
                freeModeTimer -= currentTime - oldTime
                toolbarNode.centerLabelText = freeModeTimer.fixedFractionDigits(1)
                if freeModeTimer <= GameSettings.timeUntilWarning{
                    toolbarNode.centerLabelColor = UIColor.redColor()
                }else{
                    toolbarNode.centerLabelColor = UIColor.whiteColor()
                }
            }
        }
        if gameMode == .Level {
            if let oldTime = timeSinceLastUpdate{
                for block in level!.blocks{
                    block.preferedPushTime! -= currentTime - oldTime
                    if block.preferedPushTime < 0{
                        level?.blocks.removeAtIndex((level?.blocks.indexOf(block))!)
                        switch UIApplication.sharedApplication().statusBarOrientation {
                        case .LandscapeLeft:
                            block.switchOrientationToRight()
                        case .LandscapeRight:
                            block.switchOrientationToLeft()
                        case .PortraitUpsideDown:
                            block.switchOrientationToRight()
                            block.switchOrientationToRight()
                        default:
                            break
                        }
                        GameSettings.lastKnownOrientation = UIDevice.currentDevice().orientation
                        block.position.x *= GameSettings.playableAreaSize.width
                        block.position.y *= GameSettings.playableAreaSize.height
                        addChild(block)
                    }
                }
            }
        }
        else if dynamicChildren.count < GameSettings.maxNumberOfBlocks{
            if let oldTime = timeSinceLastUpdate{
                timeToNextBlockPush -= currentTime - oldTime
                if timeToNextBlockPush < 0 {
                    let block = gameMode == .Menu ? BluredBlock() : Block()
                    let testNode = SKSpriteNode()
                    testNode.size = CGSize(width: block.frame.width * 2, height:block.frame.height * 2)
                    testNode.position = block.position
                    var testPassed = true
                    for node in children{
                        if let comparableNode = node as? Block{
                            if testNode.intersectsNode(comparableNode){
                                testPassed = false
                                break
                            }
                        }
                    }
                    if testPassed{
                        timeToNextBlockPush += GameSettings.pushBlockInterval
                        addChild(block)
                    }
                }
            }
        }
        isThereUnpushedBlocks = false
        if level?.blocks.count > 0{
            isThereUnpushedBlocks = true
        }
        for node in children{
            if let block = node as? Block{
                if !block.pushed{
                    if intersectsNode(block){
                        block.pushed = true
                    }else{
                        isThereUnpushedBlocks = true
                    }
                }
                block.physicsBody?.velocity = block.velocity
                if block.pushed && !intersectsNode(block){
                    block.physicsBody = nil
                    block.removeFromParent()
                    blockLeftGameArea = true
                }
                if block.physicsBody != nil{
                    block.animate()
                }
            }
        }
        if startTime == nil{
            startTime = currentTime
        }
        checkResult(currentTime)
        timeSinceLastUpdate = currentTime
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
