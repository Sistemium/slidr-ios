//
//  GameScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 03/05/16.
//  Copyright (c) 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum GameMode{
    case free,level,menu,challenge
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var timeSinceLastUpdate:CFTimeInterval?
    
    var startTime:CFTimeInterval?
    
    var timeToNextBlockPush = GameSettings.pushBlockInterval
    
    fileprivate var toolbarNode : ToolbarNode!{
        willSet{
            toolbarNode?.removeFromParent()
        }
        didSet{
            switch gameMode{
            case .level:
                addChild(toolbarNode)
                toolbarNode.leftLabelText = level?.name ?? ""
                toolbarNode.rightButton = toolbarNode.backButton
            case .challenge:
                addChild(toolbarNode)
                toolbarNode.leftLabelText = level?.name ?? ""
                toolbarNode.rightButton = toolbarNode.backButton
                toolbarNode.progressBarEnabled = true
            case .free:
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
                if level!.type == .Puzzle{
                    gameMode = .level
                }else{
                    gameMode = .challenge
                }
            }else{
                gameMode = .free
            }
        }
    }
    
    var gameMode:GameMode = .free
    
    var blockLeftGameArea = false
    
    var isThereUnpushedBlocks = false
    
    var freeModeTimer = GameSettings.freeModeTimer
    
    fileprivate func checkResult(_ currentTime: CFTimeInterval){
        switch gameMode{
        case .level:
            if blockLeftGameArea {
                presentResultScene(.lose, infoText: "Block left game area!")
            }
            else if level?.timeout<=0 {
                presentResultScene(.lose, infoText: "Time's Up!")
            }
            else if !isThereUnpushedBlocks && dynamicChildren.count == 0{
                presentResultScene(.win, infoText: "")
            }
        case .free:
            if freeModeTimer <= 0 {
                presentResultScene(.lose, infoText: "Time's Up!",score: currentTime - startTime!)
            }
        case .challenge:
            if level?.timeout<=0 {
                presentResultScene(.lose, infoText: "Time's Up!",completionPercent: Int((currentTime - startTime!) / level!.completionTime! * 100) )
            }
            else if (currentTime - startTime!) > level!.completionTime{
                presentResultScene(.win, infoText: "")
            }else{
                toolbarNode.progressBarCompletion = CGFloat((currentTime - startTime!) / level!.completionTime!)
            }
        default:
            break
        }
    }
    
    fileprivate func presentResultScene(_ result:Result,infoText:String,score:CFTimeInterval? = nil, completionPercent:Int? = nil){
        let scene = GameResultScene()
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .fill
        scene.result = result
        scene.finishedLevel = level ?? nil
        scene.infoText = infoText
        if let scoreTime = score{
            scene.scoreTime = scoreTime
        }
        if let scorePercent = completionPercent{
            scene.scorePercent = scorePercent
        }
        view!.presentScene(scene)
    }
    
    func randomizeReward(_ reward:Double)->Double{
        return Range(uncheckedBounds: ((reward - reward / 2),(reward + reward / 2))).random()
    }
    
    fileprivate func destroyBlock(_ block:Block,withTime time:Double, withReward reward:Double? = nil){
        var time = time
        var reward = reward
        if reward != nil && (gameMode == .free || gameMode == .challenge){
            reward = randomizeReward(reward!)
            let score = SKLabelNode(fontNamed:"Chalkduster")
            addChild(score)
            score.position = block.position
            score.fontSize = GameSettings.toolbarHeight / 1.5
            score.zPosition = 1.5
            score.fontColor = UIColor.green
            score.text = "+" + reward!.fixedFractionDigits(1)
            let group = SKAction.group([SKAction.fadeOut(withDuration: time * 2),SKAction.moveByY(200, duration: time * 2)])
            score.run(group, completion: {
                score.removeFromParent()
            })
            freeModeTimer += reward!
            level?.timeout! += reward!
        }
        if gameMode == .menu && time == 0{
            time = GameSettings.blockFadeoutTime
        }
        if block.type == .bomb && time == 0{
            let ripple = RippleCircle(radius: GameSettings.rippleRadius, position: block.position)
            ripple.strokeColor = UIColor.yellow
            ripple.lineWidth = GameSettings.rippleLineWidth
            addChild(ripple)
            ripple.ripple(GameSettings.rippleRadius, duration: 0.75)
            ripple.removeFromParent()
        }
        block.run(SKAction.fadeOut(withDuration: time), completion: {
            block.removeFromParent()
        })
    }
    
    fileprivate func repulseBlock(_ block:Block,fromWall wall:Block,withContactPoint point:CGPoint){
        if wall.rotation != 0{
            if convert(point, to: block).distance(block.corners[0]) <= (abs(block.pushVector.dy) + abs(block.pushVector.dx))/10{
                if block.pushVector.dy != 0{
                    block.pushVector = CGVector(dx: -abs(block.pushVector.dy), dy: 0)
                }else{
                    block.pushVector = CGVector(dx: 0, dy: -abs(block.pushVector.dx))
                }
                return
            }
            if convert(point, to: block).distance(block.corners[1]) <= (abs(block.pushVector.dy) + abs(block.pushVector.dx))/10{
                if block.pushVector.dy != 0{
                    block.pushVector = CGVector(dx: -abs(block.pushVector.dy), dy: 0)
                }else{
                    block.pushVector = CGVector(dx: 0, dy: abs(block.pushVector.dx))
                }
                return
            }
            if convert(point, to: block).distance(block.corners[2]) <= (abs(block.pushVector.dy) + abs(block.pushVector.dx))/10{
                if block.pushVector.dy != 0{
                    block.pushVector = CGVector(dx: abs(block.pushVector.dy), dy: 0)
                }else{
                    block.pushVector = CGVector(dx: 0, dy: abs(block.pushVector.dx))
                }
                return
            }
            if convert(point, to: block).distance(block.corners[3]) <= (abs(block.pushVector.dy) + abs(block.pushVector.dx))/10{
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
    
    func nullVelocityCollisionOccuredWith(_ block1:Block,block2:Block) -> Bool{
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
        if loseOfSpeedOfBlock1.isNaN || loseOfSpeedOfBlock1.isInfinite{
            loseOfSpeedOfBlock1 = 1
        }
        if loseOfSpeedOfBlock2.isNaN || loseOfSpeedOfBlock2.isInfinite{
            loseOfSpeedOfBlock2 = 1
        }
        if (loseOfSpeedOfBlock1.toInt() ?? 1) == 1 && (loseOfSpeedOfBlock2.toInt() ?? 1) == 1{
            return true
        }
        return false
    }
    
    func backToBackCollisionOccuredWith(_ block1:Block,block2:Block) -> Bool{
        if block1.pushVector.dx == -block2.pushVector.dx && block1.pushVector.dy == -block2.pushVector.dy{
            if block1.pushVector.dx > 0 && max(block1.position.x,block2.position.x) == block1.position.x{
                return true
            }
            if block1.pushVector.dx < 0 && min(block1.position.x,block2.position.x) == block1.position.x{
                return true
            }
            if block1.pushVector.dy > 0 && max(block1.position.y,block2.position.y) == block1.position.y{
                return true
            }
            if block1.pushVector.dy < 0 && min(block1.position.y,block2.position.y) == block1.position.y{
                return true
            }
        }
        return false
    }
    
    func whoHitted(_ block1:Block,block2:Block) -> Block?{
        if block1.pushVector.dx > 0 && block2.pushVector.dy != 0{
            if block1.position.x<block2.position.x && (block2.position.x - block1.position.x) >= block1.size.width/2 + block2.size.width/2{
                return block1
            }else{
                return block2
            }
        }
        if block2.pushVector.dx > 0 && block1.pushVector.dy != 0{
            if block2.position.x<block1.position.x && (block1.position.x - block2.position.x) >= block2.size.width/2 + block1.size.width/2{
                return block2
            }else{
                return block1
            }
        }
        if block1.pushVector.dx < 0 && block2.pushVector.dy != 0{
            if block1.position.x>block2.position.x && (block1.position.x - block2.position.x) >= block1.size.width/2 + block2.size.width/2{
                return block1
            }else{
                return block2
            }
        }
        if block2.pushVector.dx < 0 && block1.pushVector.dy != 0{
            if block2.position.x>block1.position.x && (block2.position.x - block1.position.x) >= block2.size.width/2 + block1.size.width/2{
                return block2
            }else{
                return block1
            }
        }
        return nil
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
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
                if backToBackCollisionOccuredWith(block1,block2: block2) {
                    return
                }
                if block1.type == block2.type {
                    block1.physicsBody = nil
                    block2.physicsBody = nil
                    if block1.type == .standart{
                        destroyBlock(block1,withTime: GameSettings.blockFadeoutTime, withReward:Double(GameSettings.rewardValue * block1.originalSize.height * block1.originalSize.width))
                        destroyBlock(block2,withTime: GameSettings.blockFadeoutTime, withReward:Double(GameSettings.rewardValue * block2.originalSize.height * block2.originalSize.width))
                    }
                    if block1.type == .swipeable{
                        destroyBlock(block1,withTime: GameSettings.blockFadeoutTime, withReward:Double(GameSettings.rewardValue * block1.originalSize.height * block1.originalSize.width))
                        destroyBlock(block2,withTime: GameSettings.blockFadeoutTime, withReward:Double(GameSettings.rewardValue * block2.originalSize.height * block2.originalSize.width))
                    }
                    if block1.type == .bomb{
                        destroyBlock(block1,withTime: 0)
                        destroyBlock(block2,withTime: 0)
                    }
                }else{
                    block1.pushVector = CGVector(dx: -block1.pushVector.dx, dy: -block1.pushVector.dy)
                    block2.pushVector = CGVector(dx: -block2.pushVector.dx, dy: -block2.pushVector.dy)
//                    if block1.type == .bomb{
//                        block1.physicsBody = nil
//                        destroyBlock(block1,withTime: GameSettings.blockFadeoutTime)
//                    }
//                    if block2.type == .bomb{
//                        block2.physicsBody = nil
//                        destroyBlock(block2,withTime: GameSettings.blockFadeoutTime)
//                    }
                }
            }else{
                if block1.pushVector.dx == block2.pushVector.dx && block1.pushVector.dy == block2.pushVector.dy{
                    if abs(block1.velocity.dx + block1.velocity.dy) > abs(block2.velocity.dx + block2.velocity.dy){
                        block1.pushVector = CGVector(dx: -block1.pushVector.dx, dy: -block1.pushVector.dy)
                    }else{
                        block2.pushVector = CGVector(dx: -block2.pushVector.dx, dy: -block2.pushVector.dy)
                    }
                    if block1.type == .bomb && block2.type == .bomb{
                        block2.physicsBody = nil
                        destroyBlock(block2,withTime: 0)
                        block1.physicsBody = nil
                        destroyBlock(block1,withTime: 0)
                        return
                    }
//                    if block1.type == .bomb{
//                        block1.physicsBody = nil
//                        destroyBlock(block1,withTime: GameSettings.blockFadeoutTime)
//                    }
//                    if block2.type == .bomb{
//                        block2.physicsBody = nil
//                        destroyBlock(block2,withTime: GameSettings.blockFadeoutTime)
//                    }
                }
                else{
                    if whoHitted(block1,block2: block2) == block1{
                        block2.pushVector = CGVector(dx: block1.pushVector.dx, dy: block1.pushVector.dy)
                        block1.pushVector = CGVector(dx: -block1.pushVector.dx, dy: -block1.pushVector.dy)
                    }else{
                        block1.pushVector = CGVector(dx: block2.pushVector.dx, dy: block2.pushVector.dy)
                        block2.pushVector = CGVector(dx: -block2.pushVector.dx, dy: -block2.pushVector.dy)
                    }
                    if block1.type == .bomb && block2.type == .bomb{
                        block2.physicsBody = nil
                        destroyBlock(block2,withTime: 0)
                        block1.physicsBody = nil
                        destroyBlock(block1,withTime: 0)
                        return
                    }
//                    if block1.type == .bomb{
//                        block1.physicsBody = nil
//                        destroyBlock(block1,withTime: GameSettings.blockFadeoutTime)
//                    }
//                    if block2.type == .bomb{
//                        block2.physicsBody = nil
//                        destroyBlock(block2,withTime: GameSettings.blockFadeoutTime)
//                    }
                }
            }
        }else{
            if let block = contact.bodyA.node as? Block ?? contact.bodyB.node as? Block{
                if block.type == .bomb && block.physicsBody != nil{
                    block.physicsBody = nil
                    destroyBlock(block,withTime: 0)
                    return
                }else{
                    block.physicsBody = nil
                    var reward:Double? = nil
                    freeModeTimer += Double(GameSettings.rewardValue * block.originalSize.height * block.originalSize.width)
                    reward = Double(GameSettings.rewardValue * block.originalSize.height * block.originalSize.width)
                    destroyBlock(block,withTime: GameSettings.blockFadeoutTime, withReward:reward)
                }
            }
        }
    }
    
    fileprivate func returnToPreviousScene(){
        let scene = previousScene!
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .fill
        view!.presentScene(scene)
    }
    
    // MARK: User interactions
    
    func nodeInPoint(_ p: CGPoint) -> SKNode? { //node at point is not very trustable
        return nodes(at: p).filter{return $0.zPosition == 1.0 || $0.zPosition == 33.0}.sorted{return $0.zPosition < $1.zPosition}.last
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for toch in touches{
            let location = toch.location(in: self)
            toch.startX = location.x
            toch.startY = location.y
        }
    }
    
    fileprivate func determinateSwipeDirection(_ dx:CGFloat,_ dy:CGFloat) -> UISwipeGestureRecognizerDirection?{
        if abs(dx) > abs(dy) {
            if dx < 0{
                return .left
            }
            if dx > 0{
                return .right
            }
        }
        if abs(dx) < abs(dy) {
            if dy < 0{
                return .down
            }
            if dy > 0{
                return .up
            }
        }
        return nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        tochesCycle: for toch in touches{
            let location = toch.location(in: self)
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
            
            var candidatesToGesture:[CGFloat:Block] = [:]
            
            for node in children{
                if let block = node as? Block{
                    let location = convert(location, to: block)
                    if block.physicsBody != nil && (block.type == .swipeable || block.type == .standart || block.type == .bomb){
                        candidatesToGesture[location.distance(block.anchorPoint)] = block
                    }
                }
            }
            if candidatesToGesture.keys.min() != nil {
                let chosen = candidatesToGesture[candidatesToGesture.keys.min()!]
                let touchLocation = convert(location, to: chosen!)
                let region = SKRegion(size: CGSize(width: chosen!.size.width + GameSettings.touchRegion, height: chosen!.size.height + GameSettings.touchRegion))
                if region.contains(touchLocation){
                    if chosen!.type == .bomb && chosen!.physicsBody != nil{
                        chosen!.physicsBody = nil
                        destroyBlock(chosen!,withTime: 0)
                        continue tochesCycle
                    }
                    if chosen!.physicsBody != nil && (chosen!.numberOfActions == nil || chosen!.numberOfActions! > 0){
                        chosen!.pushVector = CGVector(dx: -chosen!.pushVector.dx, dy: -chosen!.pushVector.dy)
                    }
                    if chosen!.numberOfActions != nil{
                        chosen!.numberOfActions! -= 1
                    }
                }
            }
        }
    }
    
    func swipe(_ touchLocation:CGPoint, direction:UISwipeGestureRecognizerDirection){
        let block = nodeInPoint(touchLocation) as? Block
        if block != nil && block?.physicsBody != nil{
            if (block!.type == .standart || block!.type == .swipeable) && (block!.numberOfActions == nil || block!.numberOfActions! > 0){
                if block?.type == .standart{
                    switch direction {
                    case UISwipeGestureRecognizerDirection.up:
                        if block?.pushVector.dy != 0 {
                            block?.boost = GameSettings.boostValue
                            block?.pushVector = GameSettings.moveDirections[0]
                        }
                    case UISwipeGestureRecognizerDirection.down:
                        if block?.pushVector.dy != 0 {
                            block?.boost = GameSettings.boostValue
                            block?.pushVector = GameSettings.moveDirections[1]
                        }
                    case UISwipeGestureRecognizerDirection.right:
                        if block?.pushVector.dx != 0 {
                            block?.boost = GameSettings.boostValue
                            block?.pushVector = GameSettings.moveDirections[2]
                        }
                    case UISwipeGestureRecognizerDirection.left:
                        if block?.pushVector.dx != 0 {
                            block?.boost = GameSettings.boostValue
                            block?.pushVector = GameSettings.moveDirections[3]
                        }
                    default:
                        break
                    }
                }else{
                    switch direction {
                    case UISwipeGestureRecognizerDirection.up:
                        block?.boost = GameSettings.boostValue
                        block?.pushVector = GameSettings.moveDirections[0]
                    case UISwipeGestureRecognizerDirection.down:
                        block?.boost = GameSettings.boostValue
                        block?.pushVector = GameSettings.moveDirections[1]
                    case UISwipeGestureRecognizerDirection.right:
                        block?.boost = GameSettings.boostValue
                        block?.pushVector = GameSettings.moveDirections[2]
                    case UISwipeGestureRecognizerDirection.left:
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
                let touchLocation = convert(touchLocation, to: block)
                if block.physicsBody != nil && (block.type == .swipeable || block.type == .standart){
                    candidatesToGesture[touchLocation.distance(block.anchorPoint)] = block
                }
            }
        }
        if candidatesToGesture.keys.min() != nil {
            let chosen = candidatesToGesture[candidatesToGesture.keys.min()!]
            let touchLocation = convert(touchLocation, to: chosen!)
            let region = SKRegion(size: CGSize(width: chosen!.size.width + GameSettings.touchRegion, height: chosen!.size.height + GameSettings.touchRegion))
            if region.contains(touchLocation){
                if chosen!.type == .standart{
                    switch direction {
                    case UISwipeGestureRecognizerDirection.up:
                        if chosen!.pushVector.dy != 0 {
                            chosen!.boost = GameSettings.boostValue
                            chosen!.pushVector = GameSettings.moveDirections[0]
                        }
                    case UISwipeGestureRecognizerDirection.down:
                        if chosen!.pushVector.dy != 0 {
                            chosen!.boost = GameSettings.boostValue
                            chosen!.pushVector = GameSettings.moveDirections[1]
                        }
                    case UISwipeGestureRecognizerDirection.right:
                        if chosen!.pushVector.dx != 0 {
                            chosen!.boost = GameSettings.boostValue
                            chosen!.pushVector = GameSettings.moveDirections[2]
                        }
                    case UISwipeGestureRecognizerDirection.left:
                        if chosen!.pushVector.dx != 0 {
                            chosen!.boost = GameSettings.boostValue
                            chosen!.pushVector = GameSettings.moveDirections[3]
                        }
                    default:
                        break
                    }
                }else if chosen!.type == .swipeable{
                    switch direction {
                    case UISwipeGestureRecognizerDirection.up:
                        chosen!.boost = GameSettings.boostValue
                        chosen!.pushVector = GameSettings.moveDirections[0]
                    case UISwipeGestureRecognizerDirection.down:
                        chosen!.boost = GameSettings.boostValue
                        chosen!.pushVector = GameSettings.moveDirections[1]
                    case UISwipeGestureRecognizerDirection.right:
                        chosen!.boost = GameSettings.boostValue
                        chosen!.pushVector = GameSettings.moveDirections[2]
                    case UISwipeGestureRecognizerDirection.left:
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
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.lightGray
        physicsWorld.contactDelegate = self
        toolbarNode  = ToolbarNode()
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.rotationEnded), name: NSNotification.Name(rawValue: "RotationEnded"), object: nil)
    }
    
    func rotationEnded(){
        for child in children{
            if let block = child as? Block{
                block.isHidden = false
                block.movementEnabled = true
            }
        }
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        toolbarNode  = ToolbarNode()
        for child in children{
            if let block = child as? Block{
                block.isHidden = true
                block.movementEnabled = false
                block.position.x /= oldSize.width
                block.position.y /= oldSize.height
                switch (UIDevice.current.orientation,GameSettings.lastKnownOrientation) {
                case (.landscapeLeft, .portrait), (.portraitUpsideDown, .landscapeLeft), (.landscapeRight, .portraitUpsideDown), (.portrait, .landscapeRight):
                    block.switchOrientationToLeft()
                case (.landscapeRight, .portrait), (.portraitUpsideDown, .landscapeRight), (.landscapeLeft, .portraitUpsideDown), (.portrait, .landscapeLeft):
                    block.switchOrientationToRight()
                case (.portraitUpsideDown, .portrait), (.portrait, .portraitUpsideDown), (.landscapeLeft, .landscapeRight), (.landscapeRight, .landscapeLeft):
                    block.switchOrientationToRight()
                    block.switchOrientationToRight()
                default:
                    break
                }
                block.position.x *= GameSettings.playableAreaSize.width
                block.position.y *= GameSettings.playableAreaSize.height
            }
        }
        GameSettings.lastKnownOrientation = UIDevice.current.orientation
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameMode == .level || gameMode == .challenge{
            if let oldTime = timeSinceLastUpdate{
                level!.timeout! -= currentTime - oldTime
                toolbarNode.centerLabelText = level!.timeout!.fixedFractionDigits(1)
                if level?.timeout <= GameSettings.timeUntilWarning{
                    toolbarNode.centerLabelColor = UIColor.red
                }else{
                    toolbarNode.centerLabelColor = UIColor.white
                }
            }
        }else{
            if let oldTime = timeSinceLastUpdate{
                freeModeTimer -= currentTime - oldTime
                toolbarNode.centerLabelText = freeModeTimer.fixedFractionDigits(1)
                if freeModeTimer <= GameSettings.timeUntilWarning{
                    toolbarNode.centerLabelColor = UIColor.red
                }else{
                    toolbarNode.centerLabelColor = UIColor.white
                }
            }
        }
        if gameMode == .level || gameMode == .challenge{
            if let oldTime = timeSinceLastUpdate{
                for block in level!.blocks{
                    block.preferedPushTime! -= currentTime - oldTime
                    if block.preferedPushTime < 0{
                        level?.blocks.remove(at: (level?.blocks.index(of: block))!)
                        switch UIApplication.shared.statusBarOrientation {
                        case .landscapeLeft:
                            block.switchOrientationToRight()
                        case .landscapeRight:
                            block.switchOrientationToLeft()
                        case .portraitUpsideDown:
                            block.switchOrientationToRight()
                            block.switchOrientationToRight()
                        default:
                            break
                        }
                        GameSettings.lastKnownOrientation = UIDevice.current.orientation
                        block.position.x *= GameSettings.playableAreaSize.width
                        block.position.y *= GameSettings.playableAreaSize.height
                        var testPassed = true
                        if block.type != .wall{
                            for node in children{
                                if let comparableNode = node as? Block{
                                    if block.intersects(comparableNode){
                                        testPassed = false
                                        break
                                    }
                                }
                            }
                        }
                        if testPassed{
                            if block.type == .wall{
                                addChild(block)
                                block.run(SKAction.fadeOut(withDuration: 0))
                                block.run(SKAction.fadeIn(withDuration: GameSettings.blockFadeoutTime))
                            }else{
                                addChild(block)
                            }
                        }else{
                            print(currentTime - startTime!)
                        }
                    }
                }
            }
        }
        else if dynamicChildren.count < (gameMode == .free ? GameSettings.maxNumberOfBlocks : 1) {
            if let oldTime = timeSinceLastUpdate{
                timeToNextBlockPush -= currentTime - oldTime
                if timeToNextBlockPush < 0 {
                    let block = gameMode == .menu ? BluredBlock() : Block()
                    let testNode = SKSpriteNode()
                    testNode.size = CGSize(width: block.frame.width * 2, height:block.frame.height * 2)
                    testNode.position = block.position
                    var testPassed = true
                    if block.type != .wall{
                        for node in children{
                            if let comparableNode = node as? Block{
                                if testNode.intersects(comparableNode){
                                    testPassed = false
                                    break
                                }
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
                    if gameMode == .free || gameMode == .menu || intersects(block) && block.originalSize.height >= block.size.height && block.originalSize.width >= block.size.width{
                        block.pushed = true
                    }else{
                        isThereUnpushedBlocks = true
                    }
                }
                block.physicsBody?.velocity = block.velocity
                if block.pushed && !intersects(block){
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
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        NotificationCenter.default.removeObserver(self)
    }
    
}
