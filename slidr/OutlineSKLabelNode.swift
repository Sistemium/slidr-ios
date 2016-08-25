//
//  OutlineSKLabelNode.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 20/07/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class OutlineSKLabelNode:SKLabelNode{
    
    private let offSetX:CGFloat = GameSettings.labelOffset
    private let offSetY:CGFloat = GameSettings.labelOffset
    
    lazy var outlineLabel : SKLabelNode = {[unowned self] in
        let _outlineLabel = SKLabelNode()
        _outlineLabel.fontName = self.fontName
        _outlineLabel.fontSize = self.fontSize
        _outlineLabel.fontColor = UIColor.blackColor()
        _outlineLabel.text = self.text
        _outlineLabel.zPosition = self.zPosition - 0.1
        _outlineLabel.position = CGPointMake(self.position.x - self.offSetX, self.position.y - self.offSetY)
        return _outlineLabel
    }()
    
    override var fontName: String?{
        didSet{
            outlineLabel.fontName = fontName
        }
    }
    
    override var fontSize: CGFloat{
        didSet{
            outlineLabel.fontSize = fontSize
        }
    }
    
    override var text: String?{
        didSet{
            outlineLabel.text = text
        }
    }
    
    override var zPosition: CGFloat{
        didSet{
            outlineLabel.zPosition = zPosition - 0.1
        }
    }
    
    override var position: CGPoint{
        didSet{
            outlineLabel.position = CGPointMake(position.x - offSetX, position.y - offSetY)
        }
    }
    
}