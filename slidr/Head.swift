//
//  Head.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 09/08/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class Head:SKSpriteNode {
    
    convenience init(){
        self.init(texture: nil, color: UIColor.clearColor(), size: CGSize())
        customInit()
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var size: CGSize{
        didSet{
            shape = SKShapeNode(ellipseOfSize: size)
        }
    }
    
    var shape:SKShapeNode!{
        didSet{
            oldValue?.removeFromParent()
            shape.strokeColor = UIColor.blackColor()
            shape.fillColor = UIColor.blackColor()
            shape.zPosition = zPosition
            addChild(shape)
        }
    }
    
    private func customInit(){
        shape = SKShapeNode(ellipseOfSize: size)
        zPosition = 1.5
    }
    
}
