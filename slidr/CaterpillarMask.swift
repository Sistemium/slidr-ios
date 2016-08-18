//
//  CaterpillarMask.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 10/08/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class CaterpillarMask: SKSpriteNode {
    
    weak var block:Block!
    
    init(block:Block,color:UIColor) {
        super.init(texture: nil, color: UIColor.clearColor(), size: block.size)
        self.block = block
        _color = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func normalizeY(y:CGFloat,height:CGFloat,newHeight:CGFloat)->CGFloat{
        return (y > 0 ? size.height / 2  - newHeight / 2: -size.height / 2 + newHeight / 2)
    }
    
    private func normalizeX(x:CGFloat,width:CGFloat,newWidth:CGFloat)->CGFloat{
        return (x > 0 ? size.width / 2 - newWidth / 2: -size.width / 2 + newWidth / 2)
    }
    
    private func render(){
        removeAllChildren()
        texture = nil
        if block.pushVector == GameSettings.moveDirections[0] || block.pushVector == GameSettings.moveDirections[1]{
            let height = block.caterpillarPartSize.height
            var differenceInHeight = block.size.height / CGFloat(block.heightCaterpillarPartsCount / 2 + 1) - height
            let width = block.size.width
            differenceInHeight -= differenceInHeight * GameSettings.caterpillarSpaceBetweenParts
            var spaceBetweenParts = (size.height - (height + differenceInHeight)) / CGFloat(block.heightCaterpillarPartsCount)
            if block.pushVector == GameSettings.moveDirections[0]{
                spaceBetweenParts = -spaceBetweenParts
            }
            if block.heightCaterpillarPartsCount > 0{
                for ii in 1...block.heightCaterpillarPartsCount{
                    let mask = SKShapeNode.init(ellipseOfSize: CGSize(width: width, height: height + differenceInHeight))
                    mask.position = CGPoint(x: block.hitSide.position.x, y:normalizeY(block.hitSide.position.y,height: block.hitSide.size.height,newHeight: block.caterpillarPartSize.height + differenceInHeight) + CGFloat(ii) * spaceBetweenParts)
                    mask.strokeColor = _color
                    mask.fillColor = _color
                    addChild(mask)
                }
            }
        }else{
            let height = block.size.height
            let width = block.caterpillarPartSize.width
            var differenceInWidth = block.size.width / CGFloat(block.widthCaterpillarPartsCount / 2 + 1) - width
            differenceInWidth -= differenceInWidth * GameSettings.caterpillarSpaceBetweenParts
            var spaceBetweenParts = (size.width - (width + differenceInWidth)) / CGFloat(block.widthCaterpillarPartsCount)
            if block.pushVector == GameSettings.moveDirections[2]{
                spaceBetweenParts = -spaceBetweenParts
            }
            if block.widthCaterpillarPartsCount>0{
                for ii in 1...block.widthCaterpillarPartsCount{
                    let mask = SKShapeNode.init(ellipseOfSize: CGSize(width: width + differenceInWidth, height: height))
                    mask.strokeColor = _color
                    mask.fillColor = _color
                    mask.position = CGPoint(x: normalizeX(block.hitSide.position.x, width: block.hitSide.size.width, newWidth: block.caterpillarPartSize.width + differenceInWidth) + CGFloat(ii) * spaceBetweenParts, y: block.hitSide.position.y)
                    addChild(mask)
                }
            }
        }
        
        if let view = parent?.scene?.view{
            texture = view.textureFromNode(self,crop: frame)
            removeAllChildren()
        }
    }
    
    private var _color:UIColor!
    
    override var size: CGSize{
        didSet{
            if block != nil {
                render()
            }
        }
    }
    
}
