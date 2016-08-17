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
    
    var actions:[SKAction] = []
    
    var blockType = BlockType.standart{
        didSet{
            switch blockType {
            case .standart:
                makeCaterpillarWithColor(UIColor.redColor())
            case .swipeable:
                makeCaterpillarWithColor(UIColor.blueColor())
            case .wall:
                self.color = UIColor.blackColor()
                self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
            case .bomb:
                self.color = UIColor.clearColor()
                self.size = CGSize(width: self.size.width/3, height: self.size.width/3)
                self.texture = SKTexture(imageNamed: "Bomb")
                self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
                self.physicsBody!.dynamic = true
                var innerShapes:[SKShapeNode] = [SKShapeNode(circleOfRadius: self.size.width / 2),SKShapeNode(circleOfRadius: self.size.width / 2)]
                innerShapes[1].xScale = 0.5
                innerShapes[1].yScale = 0.5
                let blur = SKEffectNode()
                blur.shouldRasterize = true
                blur.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius" : NSNumber(double:10.0)])!
                self.addChild(blur)
                blur.addChild(innerShapes[0])
                blur.addChild(innerShapes[1])
                blur.zPosition = 1.5
                innerShapes[0].zPosition = 1.5
                innerShapes[1].zPosition = 1.5
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
    
    private var maxWidth:CGFloat{
        get{
            return pushVector.dx != 0 ? self.originalSize.width * (1 + GameSettings.caterpillarDeepth) : self.originalSize.width
        }
    }
    private var maxHeight:CGFloat{
        get{
            return pushVector.dy != 0 ? self.originalSize.height * (1 + GameSettings.caterpillarDeepth) : self.originalSize.height
        }
    }
    private var minWidth:CGFloat{
        get{
            return pushVector.dx != 0 ? self.originalSize.width * (1 - GameSettings.caterpillarDeepth) : self.originalSize.width
        }
    }
    private var minHeight:CGFloat{
        get{
            return pushVector.dy != 0 ? self.originalSize.height * (1 - GameSettings.caterpillarDeepth) : self.originalSize.height
        }
    }
    
    lazy var caterpillarPartSize:CGSize = {
        let partsCount:CGFloat = round(2 + min(self.originalSize.width,self.originalSize.height) / GameSettings.caterpillarPartSize)
        return CGSize(width:self.originalSize.width / partsCount,height:self.originalSize.height / partsCount)
    }()
    
    var widthCaterpillarPartsCount:Int{
        return (Int(self.originalSize.width / self.caterpillarPartSize.width) - 1) * 2
    }
    
    var heightCaterpillarPartsCount:Int{
        return (Int(self.originalSize.height / self.caterpillarPartSize.height) - 1) * 2
    }
    
    private func makeCaterpillarWithColor(color:UIColor){
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.size.width, height: self.size.height))
        self.color = UIColor.clearColor()
        hitSide = Head()
        let mask = CaterpillarMask(block: self,color: color)
        mask.size = self.size
        mask.zPosition = 1.5
        self.addChild(hitSide)
        self.addChild(mask)
        var change:CGFloat = 1
        actions.append(SKAction.runBlock({ [unowned self] in
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
            mask.size = self.size
            if self.physicsBody != nil{
                self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.size.width, height: self.size.height))
            }
            self.pushVector = CGVector(dx: self.pushVector.dx,dy: self.pushVector.dy)
            self.physicsBody?.velocity = self.velocity
        }))
    }
    
    override var physicsBody: SKPhysicsBody?{
        didSet{
            self.physicsBody?.allowsRotation = false
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.contactTestBitMask = Block.blockId
            if self.blockType == .wall{
                self.physicsBody?.dynamic = false
            }else{
                self.physicsBody?.dynamic = true
            }
        }
    }
    
    var rotation:Double? = 0{
        didSet{
            if rotation != nil{
                self.zRotation = CGFloat(M_PI/(360/rotation!))
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
            hitSide?.size = CGSize(width: caterpillarPartSize.width, height: self.size.height)
            hitSide?.position = CGPoint(x: -self.size.width / 2 + caterpillarPartSize.width / 2, y: 0)
        case (let x,_) where x>0:
            hitSide?.size = CGSize(width: caterpillarPartSize.width, height: self.size.height)
            hitSide?.position = CGPoint(x: self.size.width / 2 - caterpillarPartSize.width / 2, y: 0)
        case (_,let y) where y<0:
            hitSide?.size = CGSize(width: self.size.width, height: caterpillarPartSize.height)
            hitSide?.position = CGPoint(x: 0, y: -self.size.height / 2 + caterpillarPartSize.height / 2)
        case (_,let y) where y>0:
            hitSide?.size = CGSize(width: self.size.width, height: caterpillarPartSize.height)
            hitSide?.position = CGPoint(x: 0, y: self.size.height / 2 - caterpillarPartSize.height / 2)
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
                return CGVectorMake(pushVector.dx / self.size.height * speedModifier * boost, pushVector.dy / self.size.width * speedModifier * boost)
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
            updateHitSide()
        }
    }
    
    static var blockId:UInt32 = 0
    
    var corners:[CGPoint]{
        get{
            return [CGPoint(x:  self.size.width / 2 , y: self.size.height / 2 ),CGPoint(x:  self.size.width / 2 , y: -self.size.height / 2 ),CGPoint(x:  -self.size.width / 2 , y: -self.size.height / 2 ),CGPoint(x:  -self.size.width / 2 , y: self.size.height / 2 )]
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
        self.zPosition = 1
        self.originalSize = self.size
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
        pushVector = GameSettings.moveDirections[Int(arc4random_uniform(4))]
        switch arc4random_uniform(7) {
        case 0,1,2:
            self.blockType = .standart
        case 3,4,5:
            self.blockType = .swipeable
        default:
            self.blockType = .bomb
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
        let t = self.position.x
        self.position.x = (-self.position.y + 1)
        self.position.y = t
        self.size = self.size.reversed()
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.pushVector = CGVectorMake(-self.pushVector.dy, self.pushVector.dx)
        originalSize = originalSize.reversed()
        caterpillarPartSize = caterpillarPartSize.reversed()
    }
    
    func switchOrientationToRight(){
        let t = (-self.position.x + 1)
        self.position.x = self.position.y
        self.position.y = t
        self.size = self.size.reversed()
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.pushVector = CGVectorMake(self.pushVector.dy, -self.pushVector.dx)
        originalSize = originalSize.reversed()
        caterpillarPartSize = caterpillarPartSize.reversed()
    }
}