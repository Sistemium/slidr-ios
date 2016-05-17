//
//  MenuScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 16/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    private var startGameLabel: SKLabelNode!{
        didSet{
            self.addChild(startGameLabel)
            startGameLabel.text = "Start game"
            startGameLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/1.7)
            startGameLabel.fontSize = GameSettings.labelSize
            startGameLabel.zPosition = 3.0
            startGameLabel.alpha = 0.5
            startGameLabel.fontColor = .whiteColor()
        }
    }
    
    private var freeModeLabel: SKLabelNode!{
        didSet{
            self.addChild(freeModeLabel)
            freeModeLabel.text = "Free mode"
            freeModeLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2)
            freeModeLabel.fontSize = GameSettings.labelSize
            freeModeLabel.zPosition = 3.0
            freeModeLabel.alpha = 0.5
            freeModeLabel.fontColor = .whiteColor()
        }
    }
    
    private var optionsLabel: SKLabelNode!{
        didSet{
            self.addChild(optionsLabel)
            optionsLabel.text = "Options"
            optionsLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2.4)
            optionsLabel.fontSize = GameSettings.labelSize
            optionsLabel.zPosition = 3.0
            optionsLabel.alpha = 0.5
            optionsLabel.fontColor = .whiteColor()
        }
    }
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.lightGrayColor()
        startGameLabel = SKLabelNode(fontNamed:"Chalkduster")
        freeModeLabel = SKLabelNode(fontNamed:"Chalkduster")
        optionsLabel = SKLabelNode(fontNamed:"Chalkduster")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first!.locationInNode(self)
        for node in self.children{
            if node.containsPoint(location){
                if let button = node as? SKLabelNode{
                    switch button {
                    case startGameLabel:
                        let scene = LevelScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .AspectFit
                        self.view!.presentScene(scene)
                        break
                    case freeModeLabel:
                        let scene = GameScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .AspectFit
                        self.view!.presentScene(scene)
                    case optionsLabel:
                        break
                    default:
                        break
                    }
                }
                return
            }
        }
    }
}
