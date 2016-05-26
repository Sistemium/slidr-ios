//
//  Block.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 04/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit
import Darwin

class Block: SKSpriteNode {
    
    private var rotation:Double? = 0{
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
    
    var pushed = false
    
    var pushVector : CGVector!{
        get{
            return _pushVector
        }
        set{
            if self.physicsBody != nil{
                self.velocity = CGVectorMake(newValue.dx / self.size.height, newValue.dy / self.size.width)
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
    }
    
    private static var blockId:UInt32 = 0
    
    convenience init(){
        self.init(texture: nil, color: GameSettings.blockColors[Int(arc4random_uniform(UInt32(GameSettings.blockColors.count)))], size: CGSize(width: CGFloat(arc4random_uniform(GameSettings.maxBlockSize) + GameSettings.minBlockSize), height: CGFloat(arc4random_uniform(GameSettings.maxBlockSize) + GameSettings.minBlockSize) ))
        customInit()
        randomizeData()
    }
    
    convenience init(blockData:NSDictionary){
        self.init(texture: nil, color: UIColor(CIColor: CIColor(string:blockData["color"] as! String)), size: CGSize(width: blockData["width"] as! CGFloat, height: blockData["height"] as! CGFloat ))
        customInit()
        loadBlock(blockData)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func customInit(){
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.contactTestBitMask = Block.blockId
        Block.blockId += 1
        self.addChild(hitSide)
        hitSide.color = UIColor.blackColor()
    }
    
    func loadBlock(blockData:NSDictionary){
        pushVector = CGVector(dx: blockData["pushVectorX"] as! CGFloat * GameSettings.baseSpeed, dy: blockData["pushVectorY"] as! CGFloat  * GameSettings.baseSpeed)
        position = CGPoint(x: blockData["positionX"] as! CGFloat * GameSettings.playableAreaSize.width, y: blockData["positionY"] as! CGFloat * GameSettings.playableAreaSize.height)
        preferedPushTime = blockData["pushTime"] as? Double
        self.rotation = blockData["rotation"] as? Double
    }
    
    func randomizeData() {
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