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
            startGameLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 + GameSettings.labelSize * 1.8)
            startGameLabel.fontSize = GameSettings.labelSize
            startGameLabel.zPosition = 2.0
            startGameLabel.fontColor = .whiteColor()
            addChild(startGameLabel)
            addChild(startGameLabel.outlineLabel)
        }
    }
    
    private var challangeGameLabel: OutlineSKLabelNode!{
        didSet{
            challangeGameLabel.text = "Challange"
            challangeGameLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 + GameSettings.labelSize * 0.6)
            challangeGameLabel.fontSize = GameSettings.labelSize
            challangeGameLabel.zPosition = 2.0
            challangeGameLabel.fontColor = .whiteColor()
            addChild(challangeGameLabel)
            addChild(challangeGameLabel.outlineLabel)
        }
    }
    
    private var freeModeLabel: OutlineSKLabelNode!{
        didSet{
            freeModeLabel.text = "Free play"
            freeModeLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 0.6)
            freeModeLabel.fontSize = GameSettings.labelSize
            freeModeLabel.zPosition = 2.0
            freeModeLabel.fontColor = .whiteColor()
            addChild(freeModeLabel)
            addChild(freeModeLabel.outlineLabel)
        }
    }
    
    private var optionsLabel: OutlineSKLabelNode!{
        didSet{
            optionsLabel.text = "Options"
            optionsLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 1.8)
            optionsLabel.fontSize = GameSettings.labelSize
            optionsLabel.zPosition = 2.0
            optionsLabel.fontColor = .whiteColor()
            addChild(optionsLabel)
            addChild(optionsLabel.outlineLabel)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first!.locationInNode(self)
        for node in children{
            if node.containsPoint(location){
                if let button = node as? OutlineSKLabelNode{
                    switch button {
                    case startGameLabel:
                        let scene = LevelScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .Fill
                        scene.previousScene = MenuScene()
                        view!.presentScene(scene)
                    case challangeGameLabel:
                        let scene = ChallangeLevelScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .Fill
                        scene.previousScene = MenuScene()
                        view!.presentScene(scene)
                        break
                    case freeModeLabel:
                        let scene = GameScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .Fill
                        scene.previousScene = MenuScene()
                        view!.presentScene(scene)
                    case optionsLabel:
                        let scene = OptionsScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .Fill
                        scene.previousScene = MenuScene()
                        view!.presentScene(scene)
                    default:
                        break
                    }
                }
                return
            }
        }
    }
    
    override func didChangeSize(oldSize: CGSize) {
        for child in children{
            child.removeFromParent()
        }
        backgroundColor = UIColor.lightGrayColor()
        startGameLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        freeModeLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        optionsLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        challangeGameLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
    }
}
