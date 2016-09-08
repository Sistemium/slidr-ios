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
            self.physicsBody?.velocity = self.velocity
        }
    }
}