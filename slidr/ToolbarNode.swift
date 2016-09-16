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
        self.init(texture: nil, color: UIColor.darkGray, size: CGSize(width: GameSettings.playableAreaSize.width, height: GameSettings.toolbarHeight))
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height - GameSettings.toolbarHeight/2)
        zPosition = 22
        alpha = 0.97
        ({leftLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")})()
        ({centerLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")})()
        ({backButton = SKSpriteNode(texture: SKTexture(imageNamed: "Back"), size: CGSize(width: GameSettings.toolbarHeight, height: GameSettings.toolbarHeight))})()
        ({progressBar = SKSpriteNode()})()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var centerLabelColor = UIColor.white{
        didSet{
            centerLabel?.fontColor = centerLabelColor
        }
    }
    
    var leftLabelColor = UIColor.white{
        didSet{
            leftLabel?.fontColor = leftLabelColor
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
            leftLabel.isHidden = !leftLabelEnabled
        }
    }
    
    var centerLabelEnabled: Bool = true{
        didSet{
            centerLabel.isHidden = !centerLabelEnabled
        }
    }
    
    var progressBarEnabled: Bool = true{
        didSet{
            progressBar.isHidden = !progressBarEnabled
        }
    }
    
    fileprivate var leftAlignment:CGPoint{
        get{
            return CGPoint(x: -GameSettings.playableAreaSize.width/2 + leftLabel.frame.size.width/2 , y: -GameSettings.toolbarHeight/4)
        }
    }
    
    fileprivate var centerAlignment:CGPoint{
        get{
            return CGPoint(x: 0 , y: -GameSettings.toolbarHeight/4)
        }
    }
    
    fileprivate var leftLabel : OutlineSKLabelNode!{
        didSet{
            oldValue?.removeFromParent()
            addChild(leftLabel)
            addChild(leftLabel.outlineLabel)
            leftLabel.fontSize = GameSettings.toolbarHeight / 1.5
            leftLabel.zPosition = 23
        }
    }
    
    fileprivate var centerLabel : OutlineSKLabelNode!{
        didSet{
            oldValue?.removeFromParent()
            addChild(centerLabel)
            addChild(centerLabel.outlineLabel)
            centerLabel.fontSize = GameSettings.toolbarHeight / 1.5
            centerLabel.zPosition = 23
        }
    }
    
    var backButton : SKSpriteNode!{
        didSet{
            backButton.zPosition = 33
        }
    }
    
    var rightButton : SKSpriteNode!{
        willSet{
            rightButton?.removeFromParent()
        }
        didSet{
            addChild(rightButton)
            rightButton.position = CGPoint(x: GameSettings.playableAreaSize.width/2 - backButton.size.width/2 - 5, y: 0)
        }
    }
    
    fileprivate var progressBar : SKSpriteNode!{
        didSet{
            oldValue?.removeFromParent()
            progressBarEnabled = false
            progressBar.size = CGSize(width: size.width, height: 3)
            progressBar.color = UIColor.green
            progressBar.zPosition = 23
            addChild(progressBar)
            progressBarCompletion = 0.0
        }
    }
    
    var progressBarCompletion:CGFloat?{
        didSet{
            progressBar.size.width = GameSettings.playableAreaSize.width * (progressBarCompletion ?? 0)
            progressBar.position = CGPoint(x: -GameSettings.playableAreaSize.width/2 + progressBar.size.width/2 * (progressBarCompletion ?? 0), y: -self.size.height/2 - progressBar.size.height/2)
        }
    }
}
