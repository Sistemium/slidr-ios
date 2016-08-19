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
    
    var originalSize = CGSize()
    private var change:CGFloat = 1
    private var innerShapes:[SKShapeNode]!
    private var mask:CaterpillarMask!
    var type = BlockType.standart{
        didSet{
            switch type {
            case .standart:
                makeCaterpillarWithColor(UIColor.redColor())
            case .swipeable:
                makeCaterpillarWithColor(UIColor.blueColor())
            case .wall:
                color = UIColor.blackColor()
                physicsBody = SKPhysicsBody(rectangleOfSize: size)
            case .bomb:
                color = UIColor.clearColor()
                size = CGSize(width: size.width/3, height: size.width/3)
                texture = SKTexture(imageNamed: "Bomb")
                physicsBody = SKPhysicsBody(rectangleOfSize: size)
                physicsBody!.dynamic = true
                innerShapes = [SKShapeNode(circleOfRadius: size.width / 2),SKShapeNode(circleOfRadius: size.width / 2)]
                innerShapes[1].xScale = 0.5
                innerShapes[1].yScale = 0.5
                let blur = SKEffectNode()
                blur.shouldRasterize = true
                blur.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius" : NSNumber(double:10.0)])!
                addChild(blur)
                blur.addChild(innerShapes[0])
                blur.addChild(innerShapes[1])
                blur.zPosition = 1.5
                innerShapes[0].zPosition = 1.5
                innerShapes[1].zPosition = 1.5
            }
        }
    }
    
    private var maxWidth:CGFloat{
        get{
            return pushVector.dx != 0 ? originalSize.width * (1 + GameSettings.caterpillarDeepth) : originalSize.width
        }
    }
    private var maxHeight:CGFloat{
        get{
            return pushVector.dy != 0 ? originalSize.height * (1 + GameSettings.caterpillarDeepth) : originalSize.height
        }
    }
    private var minWidth:CGFloat{
        get{
            return pushVector.dx != 0 ? originalSize.width * (1 - GameSettings.caterpillarDeepth) : originalSize.width
        }
    }
    private var minHeight:CGFloat{
        get{
            return pushVector.dy != 0 ? originalSize.height * (1 - GameSettings.caterpillarDeepth) : originalSize.height
        }
    }
    
    lazy var caterpillarPartSize:CGSize = {[unowned self] in
        let partsCount:CGFloat = round(2 + min(self.originalSize.width,self.originalSize.height) / GameSettings.caterpillarPartSize)
        return CGSize(width:self.originalSize.width / partsCount,height:self.originalSize.height / partsCount)
    }()
    
    var widthCaterpillarPartsCount:Int{
        return (Int(originalSize.width / caterpillarPartSize.width) - 1) * 2
    }
    
    var heightCaterpillarPartsCount:Int{
        return (Int(originalSize.height / caterpillarPartSize.height) - 1) * 2
    }
    
    private func makeCaterpillarWithColor(color:UIColor){
        physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: size.width, height: size.height))
        self.color = UIColor.clearColor()
        hitSide = Head()
        mask = CaterpillarMask(block: self,color: color)
        mask.size = size
        mask.zPosition = 1.5
        addChild(hitSide)
        addChild(mask)
    }
    
    func animate(){
        if type == .bomb{
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
        }else{
            if change<0{
                change = (-abs(self.velocity.dx + self.velocity.dy)) * GameSettings.caterpillarSpeed
            }else{
                change = abs(self.velocity.dx + self.velocity.dy) * GameSettings.caterpillarSpeed
            }
            if self.pushVector == GameSettings.moveDirections[0] || self.pushVector == GameSettings.moveDirections[1]{
                self.size = CGSize(width: self.size.width, height: self.size.height + change)
                if self.size.height < self.minHeight {
                    self.size = CGSize(width: self.size.width, height: self.minHeight)
                    change = -change
                }
                if self.size.height > self.maxHeight {
                    self.size = CGSize(width: self.size.width, height: self.maxHeight)
                    change = -change
                }
            }else{
                self.size = CGSize(width: self.size.width + change, height: self.size.height)
                if self.size.width < self.minWidth {
                    self.size = CGSize(width: self.minWidth, height: self.size.height)
                    change = -change
                }
                if self.size.width > self.maxWidth {
                    self.size = CGSize(width: self.maxWidth, height: self.size.height)
                    change = -change
                }
            }
            if self.physicsBody != nil{
                self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.size.width, height: self.size.height))
            }
            self.physicsBody?.velocity = self.velocity
            updateHitSide()
            mask?.size = self.size
        }
    }
    
    override var physicsBody: SKPhysicsBody?{
        didSet{
            physicsBody?.allowsRotation = false
            physicsBody?.affectedByGravity = false
            physicsBody?.contactTestBitMask = Block.blockId
            if type == .wall{
                physicsBody?.dynamic = false
            }else{
                physicsBody?.dynamic = true
            }
        }
    }
    
    var rotation:Double? = 0{
        didSet{
            if rotation != nil{
                zRotation = CGFloat(M_PI/(360/rotation!))
            }
        }
    }
    
    var hitSide:Head!{
        didSet{
            updateHitSide()
        }
    }
    
    private func updateHitSide(){
        switch (pushVector.dx, pushVector.dy) {
        case (let x,_) where x<0:
            hitSide?.size = CGSize(width: caterpillarPartSize.width, height: size.height)
            hitSide?.position = CGPoint(x: -size.width / 2 + caterpillarPartSize.width / 2, y: 0)
        case (let x,_) where x>0:
            hitSide?.size = CGSize(width: caterpillarPartSize.width, height: size.height)
            hitSide?.position = CGPoint(x: size.width / 2 - caterpillarPartSize.width / 2, y: 0)
        case (_,let y) where y<0:
            hitSide?.size = CGSize(width: size.width, height: caterpillarPartSize.height)
            hitSide?.position = CGPoint(x: 0, y: -size.height / 2 + caterpillarPartSize.height / 2)
        case (_,let y) where y>0:
            hitSide?.size = CGSize(width: size.width, height: caterpillarPartSize.height)
            hitSide?.position = CGPoint(x: 0, y: size.height / 2 - caterpillarPartSize.height / 2)
        default:
            break
        }
    }
    
    var movementEnabled = true
    
    var velocity:CGVector{
        get{
            if movementEnabled{
                if boost > 1{
                    boost -= 0.01
                }else{
                    boost = 1
                }
                return CGVectorMake(pushVector.dx / size.height * speedModifier * boost, pushVector.dy / size.width * speedModifier * boost)
            }else{
                return CGVectorMake(0, 0)
            }
        }
    }
    
    var preferedPushTime:Double?
    
    var numberOfActions:Int?
    
    var pushed = false
    
    private var speedModifier:CGFloat = 1
    
    var boost:CGFloat = 1
    
    var pushVector : CGVector!{
        didSet{
            animate()
        }
    }
    
    static var blockId:UInt32 = 0
    
    var corners:[CGPoint]{
        get{
            return [CGPoint(x:  size.width / 2 , y: size.height / 2 ),CGPoint(x:  size.width / 2 , y: -size.height / 2 ),CGPoint(x:  -size.width / 2 , y: -size.height / 2 ),CGPoint(x:  -size.width / 2 , y: size.height / 2 )]
        }
    }
    
    convenience init(){
        self.init(texture: nil, color: UIColor.redColor(), size: CGSize(width: CGFloat(arc4random_uniform(GameSettings.maxBlockSize) + GameSettings.minBlockSize), height: CGFloat(arc4random_uniform(GameSettings.maxBlockSize) + GameSettings.minBlockSize) ))
        randomizeData()
    }
    
    convenience init(blockData:NSDictionary){
        self.init(texture: nil, color: UIColor.redColor(), size: CGSize(width: blockData["width"] as! CGFloat, height: blockData["height"] as! CGFloat ))
        loadBlock(blockData)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func customInit(){
        Block.blockId += 1
        zPosition = 1
        originalSize = size
    }
    
    func loadBlock(blockData:NSDictionary){
        speedModifier = blockData["speedModifier"] as? CGFloat ?? 1
        pushVector = CGVector(dx: blockData["pushVectorX"] as! CGFloat * GameSettings.baseSpeed, dy: blockData["pushVectorY"] as! CGFloat  * GameSettings.baseSpeed)
        position = CGPoint(x: blockData["positionX"] as! CGFloat, y: blockData["positionY"] as! CGFloat)
        preferedPushTime = blockData["pushTime"] as? Double
        rotation = blockData["rotation"] as? Double
        numberOfActions = blockData["numberOfActions"] as? Int
        switch blockData["type"] as! String {
        case "standart":
            type = .standart
        case "swipeable":
            type = .swipeable
        case "wall":
            type = .wall
        case "bomb":
            type = .bomb
        default:
            break
        }
        if blockData["name"] as? String == "test" {
            color = UIColor.greenColor()
        }
    }
    
    func randomizeData() {
        pushVector = GameSettings.moveDirections[Int(arc4random_uniform(4))]
        switch arc4random_uniform(7) {
        case 0,1,2:
            type = .standart
        case 3,4,5:
            type = .swipeable
        default:
            type = .bomb
        }
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
        let t = position.x
        position.x = (-position.y + 1)
        position.y = t
        size = size.reversed()
        physicsBody = SKPhysicsBody(rectangleOfSize: size)
        pushVector = CGVectorMake(-pushVector.dy, pushVector.dx)
        originalSize = originalSize.reversed()
        caterpillarPartSize = caterpillarPartSize.reversed()
    }
    
    func switchOrientationToRight(){
        let t = (-position.x + 1)
        position.x = position.y
        position.y = t
        size = size.reversed()
        physicsBody = SKPhysicsBody(rectangleOfSize: size)
        pushVector = CGVectorMake(pushVector.dy, -pushVector.dx)
        originalSize = originalSize.reversed()
        caterpillarPartSize = caterpillarPartSize.reversed()
    }
}