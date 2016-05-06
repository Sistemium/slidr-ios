//
//  Block.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 04/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class Block: SKSpriteNode {
    
    var pushVector : CGVector!
    var startingPosition: CGPoint!
    
    convenience init(){
        self.init(texture: nil, color: .redColor(), size: CGSize(width: GameSettings.playableAreaSize.width / GameSettings.grid.width, height: GameSettings.playableAreaSize.height / GameSettings.grid.height))
        randomizeData()
        position = CGPoint(x: startingPosition.x * size.width + size.width / 2.0, y: startingPosition.y * size.height + size.height / 2.0)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func customInit(){
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
    }
    
    func randomizeData() {
        pushVector = GameSettings.moveDirections[Int(arc4random_uniform(4))]
        if pushVector.dx == 0{
            if pushVector.dy > 0{
                startingPosition = CGPointMake(CGFloat(arc4random_uniform(UInt32(GameSettings.grid.width))), -1)
            }else{
                startingPosition = CGPointMake(CGFloat(arc4random_uniform(UInt32(GameSettings.grid.width))), GameSettings.grid.height)
            }
        }else{
            if pushVector.dx > 0 {
                startingPosition = CGPointMake(-1, CGFloat(arc4random_uniform(UInt32(GameSettings.grid.height))))
            }else{
                startingPosition = CGPointMake(GameSettings.grid.width, CGFloat(arc4random_uniform(UInt32(GameSettings.grid.height))))
            }
        }
    }
}
