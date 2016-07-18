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
    
    var actions:[SKAction] = []
    
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
                self.color = UIColor.clearColor()
                hitSide.color = UIColor.clearColor()
                self.size = CGSize(width: self.size.width/3, height: self.size.width/3)
                self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
                self.physicsBody!.dynamic = true
                let shape = SKShapeNode(circleOfRadius: self.size.width / 2)
                shape.position = CGPoint(x: 0,y: 0)
                self.addChild(shape)
                //action for color changing animation
//                var green:CGFloat = 1.0
//                var step:CGFloat = -0.01
//                actions.append(SKAction.runBlock({
//                    green += step
//                    if green < 0.5{
//                        step = -step
//                        green = 0.5
//                    }
//                    if green > 1{
//                        step = -step
//                        green = 1
//                    }
//                    shape.fillColor = UIColor(red: 1.0, green: green, blue: 0, alpha: 1.0)
//                    shape.strokeColor = shape.fillColor
//                }))
                
                //action for ripple animation
                let innerShapes:[SKShapeNode] = [SKShapeNode(circleOfRadius: self.size.width / 2),SKShapeNode(circleOfRadius: self.size.width / 2)]
                innerShapes[1].xScale = 0.5
                innerShapes[1].yScale = 0.5
                shape.fillColor = UIColor.yellowColor()
                shape.strokeColor = shape.fillColor
                let blur = SKEffectNode()
                blur.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius" : NSNumber(double:10.0)])!
                shape.addChild(blur)
                blur.addChild(innerShapes[0])
                blur.addChild(innerShapes[1])
                actions.append(SKAction.runBlock({
                    for innerShape in innerShapes{
                        innerShape.lineWidth = 20
                        innerShape.xScale -= 0.02
                        innerShape.yScale -= 0.02
                        if innerShape.xScale <= 0{
                            innerShape.xScale = 1.0
                            innerShape.yScale = 1.0
                        }
                        innerShape.strokeColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1 - innerShape.xScale)
                        innerShape.position = CGPoint(x: 0,y: 0)
                    }
                }))
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
        switch arc4random_uniform(5) {
        case 0,1:
            self.blockType = .standart
        case 2,3:
            self.blockType = .swipeable
        default:
            self.blockType = .bomb
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
    
    func switchOrientationToLeft(){
        var t = self.position.x
        self.position.x = (-self.position.y + 1)
        self.position.y = t
        t = self.size.height
        self.size.height = self.size.width
        self.size.width = t
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        if self.blockType == .wall{
            self.physicsBody!.dynamic = false
        }
        self.pushVector = CGVectorMake(-self.pushVector.dy, self.pushVector.dx)
    }
    
    func switchOrientationToRight(){
        var t = (-self.position.x + 1)
        self.position.x = self.position.y
        self.position.y = t
        t = self.size.height
        self.size.height = self.size.width
        self.size.width = t
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        if self.blockType == .wall{
            self.physicsBody!.dynamic = false
        }
        self.pushVector = CGVectorMake(self.pushVector.dy, -self.pushVector.dx)
    }
}