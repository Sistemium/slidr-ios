//
//  BluredBlock.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 19/07/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class BluredBlock: Block {
    var skEffectNode:SKEffectNode!{
        didSet{
            skEffectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius" : NSNumber(double:GameSettings.blurValue * 4)])!
            skEffectNode.shouldRasterize = true
        }
    }
    
    private var blockView = SKSpriteNode()
    
    override var size: CGSize{
        didSet{
            blockView.size = size
        }
    }
    
    override var texture: SKTexture?{
        didSet{
            blockView.texture = texture
            super.texture = nil
        }
    }
    
    override var color: UIColor{
        set{
            blockView.color = newValue
        }
        get{
            return blockView.color
        }
    }
    
    override func addChild(node: SKNode) {
        skEffectNode.addChild(node)
    }
    
    override func customInit(){
        super.customInit()
        skEffectNode = SKEffectNode()
        super.addChild(skEffectNode)
        addChild(blockView)
        super.color = UIColor.clearColor()
    }
    
    override func updateHitSide() {
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
    
    override func animate() {
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
}