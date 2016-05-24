//
//  Block.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 04/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class Block: SKSpriteNode {
    
    private(set) var velocity : CGVector!
    
    private var _pushVector:CGVector!
    
    var preferedPushTime:Double?
    
    var pushed = false
    
    var pushVector : CGVector!{
        get{
            return _pushVector
        }
        set{
            self.velocity = CGVectorMake(newValue.dx / self.size.height, newValue.dy / self.size.width)
            _pushVector = newValue
        }
    }
    
    private static var blockId:UInt32 = 0
    
    convenience init(){
        self.init(texture: nil, color: GameSettings.blockColors[Int(arc4random_uniform(UInt32(GameSettings.blockColors.count)))], size: CGSize(width: CGFloat(arc4random_uniform(GameSettings.maxBlockSize) + GameSettings.minBlockSize), height: CGFloat(arc4random_uniform(GameSettings.maxBlockSize) + GameSettings.minBlockSize) ))
    }
    
    convenience init(blockData:NSDictionary){
        self.init(texture: nil, color: UIColor(CIColor: CIColor(string:blockData["color"] as! String)), size: CGSize(width: blockData["width"] as! CGFloat, height: blockData["height"] as! CGFloat ))
        pushVector = CGVector(dx: blockData["pushVectorX"] as! CGFloat * GameSettings.baseSpeed, dy: blockData["pushVectorY"] as! CGFloat  * GameSettings.baseSpeed)
        position = CGPoint(x: blockData["positionX"] as! CGFloat * GameSettings.playableAreaSize.width, y: blockData["positionY"] as! CGFloat * GameSettings.playableAreaSize.height)
        preferedPushTime = blockData["pushTime"] as? Double
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func customInit(){
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        if pushVector == nil {
            randomizeData()
        }
        self.physicsBody?.contactTestBitMask = Block.blockId
        Block.blockId += 1
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
