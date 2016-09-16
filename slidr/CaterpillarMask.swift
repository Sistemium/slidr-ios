//
//  CaterpillarMask.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 10/08/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

struct Dict2D<X:Hashable,Y:Hashable,V> {
    var values = [X:[Y:V]]()
    subscript (x:X, y:Y)->V? {
        get { return values[x]?[y] }
        set {
            if values[x] == nil {
                values[x] = [Y:V]()
            }
            values[x]![y] = newValue
        }
    }
}

class CaterpillarMask: SKSpriteNode {
    
    weak var block:Block!
    
    var texturesY = Dict2D<CGFloat,CGFloat,SKTexture>()
    var texturesX = Dict2D<CGFloat,CGFloat,SKTexture>()
    var textures_Y = Dict2D<CGFloat,CGFloat,SKTexture>()
    var textures_X = Dict2D<CGFloat,CGFloat,SKTexture>()
    
    init(block:Block,color:UIColor) {
        super.init(texture: nil, color: UIColor.clear, size: block.size)
        self.block = block
        _color = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func normalizeY(_ y:CGFloat,height:CGFloat,newHeight:CGFloat)->CGFloat{
        if y > 0 {
            return size.height / 2  - newHeight / 2
        }else{
            return -size.height / 2 + newHeight / 2
        }
    }
    
    fileprivate func normalizeX(_ x:CGFloat,width:CGFloat,newWidth:CGFloat)->CGFloat{
        if x > 0{
            return size.width / 2 - newWidth / 2
        }else{
            return -size.width / 2 + newWidth / 2
        }
    }
    
    fileprivate func render(){
        
        switch block.pushVector{
        case GameSettings.moveDirections[0]:
            if let textur = texturesY[block.size.width,block.size.height]{
                if texture != textur{
                    texture = textur
                }
                return
            }
        case GameSettings.moveDirections[1]:
            if let textur = textures_Y[block.size.width,block.size.height]{
                if texture != textur{
                    texture = textur
                }
                return
            }
        case GameSettings.moveDirections[2]:
            if let textur = texturesX[block.size.width,block.size.height]{
                if texture != textur{
                    texture = textur
                }
                return
            }
        case GameSettings.moveDirections[3]:
            if let textur = textures_X[block.size.width,block.size.height]{
                if texture != textur{
                    texture = textur
                }
                return
            }
        default:
            break
        }
        
        removeAllChildren()
        texture = nil
        block.updateHitSide()
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
                    let mask = SKShapeNode.init(ellipseOf: CGSize(width: width, height: height + differenceInHeight))
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
                    let mask = SKShapeNode.init(ellipseOf: CGSize(width: width + differenceInWidth, height: height))
                    mask.strokeColor = _color
                    mask.fillColor = _color
                    mask.position = CGPoint(x: normalizeX(block.hitSide.position.x, width: block.hitSide.size.width, newWidth: block.caterpillarPartSize.width + differenceInWidth) + CGFloat(ii) * spaceBetweenParts, y: block.hitSide.position.y)
                    addChild(mask)
                }
            }
        }
        
        if let view = parent?.scene?.view{
            texture = view.texture(from: self,crop: frame)
            switch block.pushVector{
            case GameSettings.moveDirections[0]:
                texturesY[block.size.width,block.size.height] = texture
            case GameSettings.moveDirections[1]:
                textures_Y[block.size.width,block.size.height] = texture
            case GameSettings.moveDirections[2]:
                texturesX[block.size.width,block.size.height] = texture
            case GameSettings.moveDirections[3]:
                textures_X[block.size.width,block.size.height] = texture
            default:
                break
            }
            removeAllChildren()
        }
    }
    
    fileprivate var _color:UIColor!
    
    override var size: CGSize{
        didSet{
            if block != nil {
                render()
            }
        }
    }
    
}
