//
//  ToolbarNode.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 17/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class ToolbarNode: SKSpriteNode {
    
    convenience init(){
        self.init(texture: nil, color: UIColor.darkGrayColor(), size: CGSize(width: GameSettings.playableAreaSize.width, height: GameSettings.toolbarHeight))
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height - GameSettings.toolbarHeight/2)
        self.zPosition = 3
        self.alpha = 0.97
        leftLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        centerLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        backButton = SKSpriteNode(texture: SKTexture(imageNamed: "Back"), size: CGSize(width: GameSettings.toolbarHeight, height: GameSettings.toolbarHeight))
        self.addChild(leftLabel)
        self.addChild(centerLabel)
        self.addChild(leftLabel.outlineLabel)
        self.addChild(centerLabel.outlineLabel)
        self.addChild(backButton)
        backButton.position = CGPoint(x: GameSettings.playableAreaSize.width/2 - backButton.size.width/2 - 5, y: 0)
        leftLabel.fontSize = GameSettings.toolbarHeight / 1.5
        leftLabel.zPosition = 4
        centerLabel.fontSize = GameSettings.toolbarHeight / 1.5
        centerLabel.zPosition = 4
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var centerLabelColor = UIColor.whiteColor(){
        didSet{
            centerLabel.fontColor = centerLabelColor
        }
    }
    
    var leftLabelColor = UIColor.whiteColor(){
        didSet{
            leftLabel.fontColor = leftLabelColor
        }
    }
    
    var leftLabelText: String = ""{
        didSet{
            leftLabel.text = leftLabelText
            leftLabel.position = leftAlignment
        }
    }
    
    var centerLabelText: String = ""{
        didSet{
            centerLabel.text = centerLabelText
            centerLabel.position = centerAlignment
        }
    }
    
    var leftLabelEnabled: Bool = true{
        didSet{
            leftLabel.hidden = !leftLabelEnabled
        }
    }
    
    var centerLabelEnabled: Bool = true{
        didSet{
            centerLabel.hidden = !centerLabelEnabled
        }
    }
    
    private var leftAlignment:CGPoint{
        get{
            return CGPoint(x: -GameSettings.playableAreaSize.width/2 + leftLabel.frame.size.width/2 , y: -GameSettings.toolbarHeight/4)
        }
    }
    
    private var centerAlignment:CGPoint{
        get{
            return CGPoint(x: 0 , y: -GameSettings.toolbarHeight/4)
        }
    }
    
    private var leftLabel : OutlineSKLabelNode!
    
    private var centerLabel : OutlineSKLabelNode!
    
    var backButton : SKSpriteNode!
    
}
