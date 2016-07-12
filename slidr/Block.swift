//
//  Block.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 04/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit
import Darwin

enum BlockType{
    case standart, swipeable, wall, bomb
}

class Block: SKSpriteNode {
    
    var blockType = BlockType.standart{
        didSet{
            switch blockType {
            case .standart:
                self.color = UIColor.redColor()
                hitSide.color = UIColor.blackColor()
                self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
                self.physicsBody!.dynamic = true
            case .swipeable:
                self.color = UIColor.blueColor()
                hitSide.color = UIColor.blackColor()
                self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
                self.physicsBody!.dynamic = true
            case .wall:
                self.color = UIColor.blackColor()
                hitSide.color = UIColor.blackColor()
                self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
                self.physicsBody!.dynamic = false
            case .bomb:
                self.color = UIColor.yellowColor()
                hitSide.color = UIColor.clearColor()
                self.size = CGSize(width: self.size.width/3, height: self.size.height/3)
                self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
                self.physicsBody!.dynamic = true
            }
        }
    }
    
    override var physicsBody: SKPhysicsBody?{
        didSet{
            self.physicsBody?.allowsRotation = false
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.contactTestBitMask = Block.blockId
        }
    }
    
    var moveDirections:[CGVector]{
        get{
            return [CGVectorMake(0, GameSettings.baseSpeed * speedModifier),CGVectorMake(0, -GameSettings.baseSpeed * speedModifier),CGVectorMake(GameSettings.baseSpeed * speedModifier, 0),CGVectorMake(-GameSettings.baseSpeed * speedModifier, 0)]
        }
    }
    
    var rotation:Double? = 0{
        didSet{
            if rotation != nil{
                self.zRotation = CGFloat(M_PI/(360/rotation!))
            }
        }
    }
    
    private var hitSide = SKSpriteNode()
    
    private(set) var velocity : CGVector!
    
    private var _pushVector:CGVector!
    
    var preferedPushTime:Double?
    
    var numberOfActions:Int?
    
    var pushed = false
    
    private var speedModifier:CGFloat = 1
    
    var pushVector : CGVector!{
        get{
            return _pushVector
        }
        set{
            self.velocity = CGVectorMake(newValue.dx / self.size.height * speedModifier, newValue.dy / self.size.width * speedModifier)
            _pushVector = newValue
            switch (pushVector.dx, pushVector.dy) {
            case (let x,_) where x<0:
                hitSide.size = CGSize(width: GameSettings.hitSideWidth, height: self.size.height)
                hitSide.position = CGPoint(x: -self.size.width / 2 + GameSettings.hitSideWidth / 2, y: 0)
            case (let x,_) where x>0:
                hitSide.size = CGSize(width: GameSettings.hitSideWidth, height: self.size.height)
                hitSide.position = CGPoint(x: self.size.width / 2 - GameSettings.hitSideWidth / 2, y: 0)
            case (_,let y) where y<0:
                hitSide.size = CGSize(width: self.size.width, height: GameSettings.hitSideWidth)
                hitSide.position = CGPoint(x: 0, y: -self.size.height / 2 + GameSettings.hitSideWidth / 2)
            case (_,let y) where y>0:
                hitSide.size = CGSize(width: self.size.width, height: GameSettings.hitSideWidth)
                hitSide.position = CGPoint(x: 0, y: self.size.height / 2 - GameSettings.hitSideWidth / 2)
            default:
                break
            }
        }
    }
    
    private static var blockId:UInt32 = 0
    
    var corners:[CGPoint]{
        get{
            return [CGPoint(x:  self.size.width / 2 , y: self.size.height / 2 ),CGPoint(x:  self.size.width / 2 , y: -self.size.height / 2 ),CGPoint(x:  -self.size.width / 2 , y: -self.size.height / 2 ),CGPoint(x:  -self.size.width / 2 , y: self.size.height / 2 )]
        }
    }
    
    convenience init(){
        self.init(texture: nil, color: UIColor.redColor(), size: CGSize(width: CGFloat(arc4random_uniform(GameSettings.maxBlockSize) + GameSettings.minBlockSize), height: CGFloat(arc4random_uniform(GameSettings.maxBlockSize) + GameSettings.minBlockSize) ))
        randomizeData()
        customInit()
    }
    
    convenience init(blockData:NSDictionary){
        self.init(texture: nil, color: UIColor.redColor(), size: CGSize(width: blockData["width"] as! CGFloat, height: blockData["height"] as! CGFloat ))
        loadBlock(blockData)
        customInit()
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func customInit(){
        Block.blockId += 1
        self.addChild(hitSide)
    }
    
    func loadBlock(blockData:NSDictionary){
        speedModifier = blockData["speedModifier"] as? CGFloat ?? 1
        pushVector = CGVector(dx: blockData["pushVectorX"] as! CGFloat * GameSettings.baseSpeed, dy: blockData["pushVectorY"] as! CGFloat  * GameSettings.baseSpeed)
        position = CGPoint(x: blockData["positionX"] as! CGFloat, y: blockData["positionY"] as! CGFloat)
        preferedPushTime = blockData["pushTime"] as? Double
        self.rotation = blockData["rotation"] as? Double
        self.numberOfActions = blockData["numberOfActions"] as? Int
        switch blockData["type"] as! String {
        case "standart":
            blockType = .standart
        case "swipeable":
            self.blockType = .swipeable
        case "wall":
            self.blockType = .wall
        case "bomb":
            self.blockType = .bomb
        default:
            break
        }
    }
    
    func randomizeData() {
        switch arc4random_uniform(3) {
        case 0:
            self.blockType = .standart
        case 1:
            self.blockType = .bomb
        default:
            self.blockType = .swipeable
        }
        pushVector = GameSettings.moveDirections[Int(arc4random_uniform(4))]
        if pushVector.dx == 0{
            if pushVector.dy > 0{
                position = CGPointMake(CGFloat(arc4random_uniform(UInt32(GameSettings.playableAreaSize.width - size.width ))) + size.width/2, -size.height/2)
            }else{
                position = CGPointMake(CGFloat(arc4random_uniform(UInt32(GameSettings.playableAreaSize.width - size.width ))) + size.width/2, GameSettings.playableAreaSize.height + size.height/2)
            }
        }else{
            if pushVector.dx > 0 {
                position = CGPointMake(-size.width/2, CGFloat(arc4random_uniform(UInt32(GameSettings.playableAreaSize.height - size.height ))) + size.height/2)
            }else{
                position = CGPointMake(GameSettings.playableAreaSize.width + size.width/2, CGFloat(arc4random_uniform(UInt32(GameSettings.playableAreaSize.height - size.height ))) + size.height/2)
            }
        }
    }
}