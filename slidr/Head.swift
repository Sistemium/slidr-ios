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
        self.init(texture: nil, color: UIColor.clear, size: CGSize())
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
            shape = SKShapeNode(ellipseOf: size)
        }
    }
    
    var shape:SKShapeNode!{
        didSet{
            oldValue?.removeFromParent()
            shape.strokeColor = UIColor.black
            shape.fillColor = UIColor.black
            shape.zPosition = zPosition
            addChild(shape)
        }
    }
    
    fileprivate func customInit(){
        shape = SKShapeNode(ellipseOf: size)
        zPosition = 1.5
    }
    
    fileprivate var copy : SKSpriteNode?
    
    func animateNewPosition(_ newValue:CGPoint){
        copy = SKSpriteNode()
        copy?.addChild(shape.copy() as! SKNode)
        parent?.addChild(copy!)
        copy?.position = position
        isHidden = true
        position = newValue
        copy?.zPosition = zPosition + 0.1
        copy?.run(SKAction.move(to: newValue, duration: 0.15), completion: {[unowned self] in
            self.isHidden = false
            self.copy?.removeFromParent()
        })
    }
    
    func stopAnimation(){
        copy?.removeAllActions()
        copy?.removeFromParent()
        isHidden = false
    }
    
}
