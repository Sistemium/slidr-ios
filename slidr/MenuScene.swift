//
//  MenuScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 16/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class MenuScene: GameScene {
    
    private var startGameLabel: SKLabelNode!{
        didSet{
            self.addChild(startGameLabel)
            startGameLabel.text = "Start game"
            startGameLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 + GameSettings.labelSize * 1.3)
            startGameLabel.fontSize = GameSettings.labelSize
            startGameLabel.zPosition = 3.0
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
            freeModeLabel.fontColor = .whiteColor()
        }
    }
    
    private var optionsLabel: SKLabelNode!{
        didSet{
            self.addChild(optionsLabel)
            optionsLabel.text = "Options"
            optionsLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 1.3)
            optionsLabel.fontSize = GameSettings.labelSize
            optionsLabel.zPosition = 3.0
            optionsLabel.fontColor = .whiteColor()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first!.locationInNode(self)
        for node in self.children{
            if node.containsPoint(location){
                if let button = node as? SKLabelNode{
                    switch button {
                    case startGameLabel:
                        let scene = LevelScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .Fill
                        scene.previousScene = self
                        self.view!.presentScene(scene)
                        break
                    case freeModeLabel:
                        let scene = GameScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .Fill
                        scene.previousScene = self
                        self.view!.presentScene(scene)
                    case optionsLabel:
                        let scene = OptionsScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .Fill
                        scene.previousScene = self
                        self.view!.presentScene(scene)
                        break
                    default:
                        break
                    }
                }
                return
            }
        }
    }
    
    override func swipe(sender: UISwipeGestureRecognizer) {
    }
    
    override func didChangeSize(oldSize: CGSize) {
        for child in self.children{
            child.removeFromParent()
        }
        self.backgroundColor = UIColor.lightGrayColor()
        startGameLabel = SKLabelNode(fontNamed:"Chalkduster")
        freeModeLabel = SKLabelNode(fontNamed:"Chalkduster")
        optionsLabel = SKLabelNode(fontNamed:"Chalkduster")
    }
}
