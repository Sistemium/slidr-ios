//
//  OutlineSKLabelNode.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 20/07/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class OutlineSKLabelNode:SKLabelNode{
    
    fileprivate let offSetX:CGFloat = GameSettings.labelOffset
    fileprivate let offSetY:CGFloat = GameSettings.labelOffset
    
    lazy var outlineLabel : SKLabelNode = {[unowned self] in
        let _outlineLabel = SKLabelNode()
        _outlineLabel.fontName = self.fontName
        _outlineLabel.fontSize = self.fontSize
        _outlineLabel.fontColor = UIColor.black
        _outlineLabel.text = self.text
        _outlineLabel.zPosition = self.zPosition - 0.1
        _outlineLabel.position = CGPoint(x: self.position.x - self.offSetX, y: self.position.y - self.offSetY)
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
            outlineLabel.position = CGPoint(x: position.x - offSetX, y: position.y - offSetY)
        }
    }
    
}
