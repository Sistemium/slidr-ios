//
//  MenuScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 16/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class MenuScene: GameScene {
    
    override func didMoveToView(view: SKView) {
        gameMode = .Menu
        super.didMoveToView(view)
    }
    
    private var startGameLabel: OutlineSKLabelNode!{
        didSet{
            startGameLabel.text = "Start game"
            startGameLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 + GameSettings.labelSize * 1.3)
            startGameLabel.fontSize = GameSettings.labelSize
            startGameLabel.zPosition = 3.0
            startGameLabel.fontColor = .whiteColor()
            self.addChild(startGameLabel)
            self.addChild(startGameLabel.outlineLabel)
        }
    }
    
    private var freeModeLabel: OutlineSKLabelNode!{
        didSet{
            freeModeLabel.text = "Free mode"
            freeModeLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2)
            freeModeLabel.fontSize = GameSettings.labelSize
            freeModeLabel.zPosition = 3.0
            freeModeLabel.fontColor = .whiteColor()
            self.addChild(freeModeLabel)
            self.addChild(freeModeLabel.outlineLabel)
        }
    }
    
    private var optionsLabel: OutlineSKLabelNode!{
        didSet{
            optionsLabel.text = "Options"
            optionsLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 1.3)
            optionsLabel.fontSize = GameSettings.labelSize
            optionsLabel.zPosition = 3.0
            optionsLabel.fontColor = .whiteColor()
            self.addChild(optionsLabel)
            self.addChild(optionsLabel.outlineLabel)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first!.locationInNode(self)
        for node in self.children{
            if node.containsPoint(location){
                if let button = node as? OutlineSKLabelNode{
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
        startGameLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        freeModeLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        optionsLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
    }
}
