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
        scoreLabel = SKLabelNode(fontNamed:"Chalkduster")
        timerLabel = SKLabelNode(fontNamed:"Chalkduster")
        backButton = SKSpriteNode(texture: SKTexture(imageNamed: "Back"), size: CGSize(width: GameSettings.toolbarHeight, height: GameSettings.toolbarHeight))
        self.addChild(scoreLabel)
        self.addChild(timerLabel)
        self.addChild(backButton)
        backButton.position = CGPoint(x: GameSettings.playableAreaSize.width/2 - backButton.size.width/2 - 5, y: 0)
        scoreLabel.fontSize = GameSettings.toolbarHeight / 1.5
        scoreLabel.zPosition = 4
        scoreLabel.fontColor = .whiteColor()
        timerLabel.fontSize = GameSettings.toolbarHeight / 1.5
        timerLabel.zPosition = 4
        timerLabel.fontColor = .whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var scoreLabelText: String = ""{
        didSet{
            scoreLabel.text = scoreLabelText
            scoreLabel.position = leftAlignment
        }
    }
    
    var timerLabelText: String = ""{
        didSet{
            timerLabel.text = timerLabelText
            timerLabel.position = centerAlignment
        }
    }
    
    private var leftAlignment:CGPoint{
        get{
            return CGPoint(x: -GameSettings.playableAreaSize.width/2 + scoreLabel.frame.size.width/2 , y: -GameSettings.toolbarHeight/4)
        }
    }
    
    private var centerAlignment:CGPoint{
        get{
            return CGPoint(x: 0 , y: -GameSettings.toolbarHeight/4)
        }
    }
    
    private var scoreLabel : SKLabelNode!
    
    private var timerLabel : SKLabelNode!
    
    var backButton : SKSpriteNode!
}
