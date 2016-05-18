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
        self.alpha = 0.9
        scoreLabel = SKLabelNode(fontNamed:"Chalkduster")
        backButton = SKSpriteNode(texture: SKTexture(imageNamed: "Back"), size: CGSize(width: GameSettings.toolbarHeight, height: GameSettings.toolbarHeight))
        self.addChild(scoreLabel)
        self.addChild(backButton)
        backButton.position = CGPoint(x: GameSettings.playableAreaSize.width/2 - backButton.size.width/2 - 5, y: 0)
        scoreLabel.fontSize = GameSettings.toolbarHeight / 1.5
        scoreLabel.zPosition = 4
        scoreLabel.fontColor = .whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var text: String = ""{
        didSet{
            scoreLabel.text = text
            scoreLabel.position = CGPoint(x: -GameSettings.playableAreaSize.width/2 + scoreLabel.frame.size.width/2 , y: -GameSettings.toolbarHeight/4)
        }
    }
    
    private var scoreLabel : SKLabelNode!
    
    var backButton : SKSpriteNode!
}
