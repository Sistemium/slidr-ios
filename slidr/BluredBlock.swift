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
            skEffectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius" : NSNumber(double:40.0)])!
            skEffectNode.shouldRasterize = true
        }
    }
    
    var blockView = SKSpriteNode()
    
    override var size: CGSize{
        didSet{
            blockView.size = size
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
        Block.blockId += 1
        skEffectNode = SKEffectNode()
        super.addChild(skEffectNode)
        addChild(blockView)
        super.color = UIColor.clearColor()
        self.addChild(hitSide)
    }
}