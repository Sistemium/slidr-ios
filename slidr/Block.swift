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
    var change:CGFloat = 1
    var innerShapes:[SKShapeNode]!
    var mask:CaterpillarMask!
    var type = BlockType.standart{
        didSet{
            switch type {
            case .standart:
                makeCaterpillarWithColor(UIColor.red)
            case .swipeable:
                makeCaterpillarWithColor(UIColor.blue)
            case .wall:
                color = UIColor.black
                physicsBody = SKPhysicsBody(rectangleOf: size)
            case .bomb:
                color = UIColor.clear
                size = CGSize(width: size.width/2.5, height: size.width/2.5)
                texture = SKTexture(imageNamed: "Bomb")
                physicsBody = SKPhysicsBody(rectangleOf: size)
                physicsBody!.isDynamic = true
                innerShapes = [SKShapeNode(circleOfRadius: size.width / 2),SKShapeNode(circleOfRadius: size.width / 2)]
                innerShapes[1].xScale = 0.5
                innerShapes[1].yScale = 0.5
                let blur = SKEffectNode()
                blur.shouldRasterize = true
                blur.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius" : NSNumber(value: GameSettings.blurValue as Double)])!
                addChild(blur)
                blur.addChild(innerShapes[0])
                blur.addChild(innerShapes[1])
                blur.zPosition = 1.5
                innerShapes[0].zPosition = 1.5
                innerShapes[1].zPosition = 1.5
            }
        }
    }
    
    var maxWidth:CGFloat{
        get{
            return pushVector.dx != 0 ? originalSize.width * (1 + GameSettings.caterpillarDeepth) : originalSize.width
        }
    }
    var maxHeight:CGFloat{
        get{
            return pushVector.dy != 0 ? originalSize.height * (1 + GameSettings.caterpillarDeepth) : originalSize.height
        }
    }
    var minWidth:CGFloat{
        get{
            return pushVector.dx != 0 ? originalSize.width * (1 - GameSettings.caterpillarDeepth) : originalSize.width
        }
    }
    var minHeight:CGFloat{
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
    
    fileprivate func makeCaterpillarWithColor(_ color:UIColor){
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height))
        self.color = UIColor.clear
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
                self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
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
                physicsBody?.isDynamic = false
            }else{
                physicsBody?.isDynamic = true
            }
        }
    }
    
    var rotation:Int? = 0{
        didSet{
            if rotation != nil{
                zRotation = rotation!.deg2Rad
            }
        }
    }
    
    var hitSide:Head!{
        didSet{
            
            updateHitSide()
        }
    }
    
    var lastPushVector:CGVector?
    
    func updateHitSide(){
        if pushVector != lastPushVector {
            hitSide?.stopAnimation()
        }
        if pushVector == lastPushVector?.inverted{
            switch pushVector{
            case GameSettings.moveDirections[3]:
                hitSide?.size = CGSize(width: caterpillarPartSize.width, height: size.height)
                hitSide?.animateNewPosition(CGPoint(x: -size.width / 2 + caterpillarPartSize.width / 2, y: 0))
            case GameSettings.moveDirections[2]:
                hitSide?.size = CGSize(width: caterpillarPartSize.width, height: size.height)
                hitSide?.animateNewPosition(CGPoint(x: size.width / 2 - caterpillarPartSize.width / 2, y: 0))
            case GameSettings.moveDirections[1]:
                hitSide?.size = CGSize(width: size.width, height: caterpillarPartSize.height)
                hitSide?.animateNewPosition(CGPoint(x: 0, y: -size.height / 2 + caterpillarPartSize.height / 2))
            case GameSettings.moveDirections[0]:
                hitSide?.size = CGSize(width: size.width, height: caterpillarPartSize.height)
                hitSide?.animateNewPosition(CGPoint(x: 0, y: size.height / 2 - caterpillarPartSize.height / 2))
            default:
                break
            }
        }else{
            switch pushVector{
            case GameSettings.moveDirections[3]:
                hitSide?.size = CGSize(width: caterpillarPartSize.width, height: size.height)
                hitSide?.position = CGPoint(x: -size.width / 2 + caterpillarPartSize.width / 2, y: 0)
            case GameSettings.moveDirections[2]:
                hitSide?.size = CGSize(width: caterpillarPartSize.width, height: size.height)
                hitSide?.position = CGPoint(x: size.width / 2 - caterpillarPartSize.width / 2, y: 0)
            case GameSettings.moveDirections[1]:
                hitSide?.size = CGSize(width: size.width, height: caterpillarPartSize.height)
                hitSide?.position = CGPoint(x: 0, y: -size.height / 2 + caterpillarPartSize.height / 2)
            case GameSettings.moveDirections[0]:
                hitSide?.size = CGSize(width: size.width, height: caterpillarPartSize.height)
                hitSide?.position = CGPoint(x: 0, y: size.height / 2 - caterpillarPartSize.height / 2)
            default:
                break
            }
        }
        lastPushVector = pushVector
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
                return CGVector(dx: pushVector.dx * speedModifier * boost,dy: pushVector.dy * speedModifier * boost)
            }else{
                return CGVector(dx: 0, dy: 0)
            }
        }
    }
    
    var preferedPushTime:Double?
    
    var numberOfActions:Int?
    
    var pushed = false
    
    var speedModifier:CGFloat = 1
    
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
        self.init(texture: nil, color: UIColor.red, size: CGSize(width: CGFloat(arc4random_uniform(GameSettings.maxBlockSize) + GameSettings.minBlockSize), height: CGFloat(arc4random_uniform(GameSettings.maxBlockSize) + GameSettings.minBlockSize) ))
        randomizeData()
    }
    
    convenience init(blockData:NSDictionary){
        self.init(texture: nil, color: UIColor.red, size: CGSize(width: blockData["width"] as! CGFloat * GameSettings.rezolutionNormalizationValue, height: blockData["height"] as! CGFloat * GameSettings.rezolutionNormalizationValue))
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
    
    func loadBlock(_ blockData:NSDictionary){
        speedModifier = blockData["speedModifier"] as? CGFloat ?? 1
        pushVector = CGVector(dx: blockData["pushVectorX"] as! CGFloat * GameSettings.defaultSpeed, dy: blockData["pushVectorY"] as! CGFloat  * GameSettings.defaultSpeed)
        position = CGPoint(x: blockData["positionX"] as! CGFloat, y: blockData["positionY"] as! CGFloat)
        preferedPushTime = blockData["pushTime"] as? Double
        rotation = blockData["rotation"] as? Int
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
            color = UIColor.green
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
                position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(GameSettings.playableAreaSize.width - size.width ))) + size.width/2, y: -size.height/2)
            }else{
                position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(GameSettings.playableAreaSize.width - size.width ))) + size.width/2, y: GameSettings.playableAreaSize.height + size.height/2)
            }
        }else{
            if pushVector.dx > 0 {
                position = CGPoint(x: -size.width/2, y: CGFloat(arc4random_uniform(UInt32(GameSettings.playableAreaSize.height - size.height ))) + size.height/2)
            }else{
                position = CGPoint(x: GameSettings.playableAreaSize.width + size.width/2, y: CGFloat(arc4random_uniform(UInt32(GameSettings.playableAreaSize.height - size.height ))) + size.height/2)
            }
        }
    }
    
    func switchOrientationToLeft(){
        let t = position.x
        position.x = (-position.y + 1)
        position.y = t
        size = size.reversed()
        physicsBody = SKPhysicsBody(rectangleOf: size)
        pushVector = CGVector(dx: -pushVector.dy, dy: pushVector.dx)
        originalSize = originalSize.reversed()
        caterpillarPartSize = caterpillarPartSize.reversed()
    }
    
    func switchOrientationToRight(){
        let t = (-position.x + 1)
        position.x = position.y
        position.y = t
        size = size.reversed()
        physicsBody = SKPhysicsBody(rectangleOf: size)
        pushVector = CGVector(dx: pushVector.dy, dy: -pushVector.dx)
        originalSize = originalSize.reversed()
        caterpillarPartSize = caterpillarPartSize.reversed()
    }
}
