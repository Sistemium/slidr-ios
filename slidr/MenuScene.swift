//
//  MenuScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 16/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class MenuScene: GameScene {
    
    override func didMove(to view: SKView) {
        gameMode = .menu
        super.didMove(to: view)
    }
    
    fileprivate var levelsLabel: OutlineSKLabelNode!{
        didSet{
            levelsLabel.text = "Puzzle levels"
            levelsLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 + GameSettings.labelSize * 1.8)
            levelsLabel.fontSize = GameSettings.labelSize
            levelsLabel.zPosition = 2.0
            levelsLabel.fontColor = UIColor.white
            addChild(levelsLabel)
            addChild(levelsLabel.outlineLabel)
        }
    }
    
    fileprivate var challengeGameLabel: OutlineSKLabelNode!{
        didSet{
            challengeGameLabel.text = "Challenge"
            challengeGameLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 + GameSettings.labelSize * 0.6)
            challengeGameLabel.fontSize = GameSettings.labelSize
            challengeGameLabel.zPosition = 2.0
            challengeGameLabel.fontColor = UIColor.white
            addChild(challengeGameLabel)
            addChild(challengeGameLabel.outlineLabel)
        }
    }
    
    fileprivate var freeModeLabel: OutlineSKLabelNode!{
        didSet{
            freeModeLabel.text = "Free play"
            freeModeLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 0.6)
            freeModeLabel.fontSize = GameSettings.labelSize
            freeModeLabel.zPosition = 2.0
            freeModeLabel.fontColor = UIColor.white
            addChild(freeModeLabel)
            addChild(freeModeLabel.outlineLabel)
        }
    }
    
    fileprivate var optionsLabel: OutlineSKLabelNode!{
        didSet{
            optionsLabel.text = "Options"
            optionsLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 1.8)
            optionsLabel.fontSize = GameSettings.labelSize
            optionsLabel.zPosition = 2.0
            optionsLabel.fontColor = UIColor.white
            addChild(optionsLabel)
            addChild(optionsLabel.outlineLabel)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        for node in children{
            if node.contains(location){
                if let button = node as? OutlineSKLabelNode{
                    switch button {
                    case levelsLabel:
                        let scene = LevelScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .fill
                        scene.previousScene = MenuScene()
                        view!.presentScene(scene)
                    case challengeGameLabel:
                        let scene = ChallengeLevelScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .fill
                        scene.previousScene = MenuScene()
                        view!.presentScene(scene)
                        break
                    case freeModeLabel:
                        let scene = GameScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .fill
                        scene.previousScene = MenuScene()
                        view!.presentScene(scene)
                    case optionsLabel:
                        let scene = OptionsScene()
                        scene.size = GameSettings.playableAreaSize
                        scene.scaleMode = .fill
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
    
    override func didChangeSize(_ oldSize: CGSize) {
        for child in children{
            child.removeFromParent()
        }
        backgroundColor = UIColor.lightGray
        levelsLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        freeModeLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        optionsLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        challengeGameLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
    }
}
