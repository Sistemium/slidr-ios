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
            skEffectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius" : NSNumber(value: GameSettings.blurValue * 4 as Double)])!
            skEffectNode.shouldRasterize = true
        }
    }
    
    fileprivate var blockView = SKSpriteNode()
    
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
    
    override func addChild(_ node: SKNode) {
        skEffectNode.addChild(node)
    }
    
    override func customInit(){
        super.customInit()
        skEffectNode = SKEffectNode()
        super.addChild(skEffectNode)
        addChild(blockView)
        super.color = UIColor.clear
    }
    
//    override func animate() {
//        if type == .bomb{
//        }else{
//            self.physicsBody?.velocity = self.velocity
//        }
//    }
}
