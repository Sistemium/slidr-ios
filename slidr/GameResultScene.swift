//
//  GameResultScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 20/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

enum Result{
    case Win,Lose
}

class GameResultScene: SKScene{
    
    var result:Result = Result.Win
    
    var finishedLevel :Level?
    
    private var resultLabel: SKLabelNode!{
        didSet{
            self.addChild(resultLabel)
            resultLabel.text = result == .Win ? "You Win" : "You Lose"
            resultLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/1.7)
            resultLabel.fontSize = GameSettings.labelSize
            resultLabel.zPosition = 3.0
            resultLabel.fontColor = result == .Win ? UIColor.greenColor() : UIColor.redColor()
        }
    }
    
    private var questionLabel: SKLabelNode!{
        didSet{
            self.addChild(questionLabel)
            questionLabel.text = result == .Win ? "Play next level?" : "Play again?"
            questionLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2)
            questionLabel.fontSize = GameSettings.labelSize
            questionLabel.zPosition = 3.0
            questionLabel.fontColor = UIColor.whiteColor()
        }
    }

    private var returnButton: SKLabelNode!{
        didSet{
            self.addChild(returnButton)
            returnButton.text = "No"
            returnButton.position = CGPoint(x: GameSettings.playableAreaSize.width/3, y: GameSettings.playableAreaSize.height/2.4)
            returnButton.fontSize = GameSettings.labelSize
            returnButton.zPosition = 3.0
            returnButton.fontColor = UIColor.whiteColor()
        }
    }
    
    private var actionButton: SKLabelNode!{
        didSet{
            self.addChild(actionButton)
            actionButton.text = "Yes"
            actionButton.position = CGPoint(x: GameSettings.playableAreaSize.width/1.5, y: GameSettings.playableAreaSize.height/2.4)
            actionButton.fontSize = GameSettings.labelSize
            actionButton.zPosition = 3.0
            actionButton.fontColor = UIColor.whiteColor()
        }
    }
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.lightGrayColor()
        resultLabel = SKLabelNode(fontNamed:"Chalkduster")
        questionLabel = SKLabelNode(fontNamed:"Chalkduster")
        returnButton = SKLabelNode(fontNamed:"Chalkduster")
        actionButton = SKLabelNode(fontNamed:"Chalkduster")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first!.locationInNode(self)
        let node = self.nodeAtPoint(location)
        switch node {
        case returnButton:
            let scene = LevelScene()
            scene.size = GameSettings.playableAreaSize
            scene.scaleMode = .AspectFit
            scene.previousScene = MenuScene()
            self.view!.presentScene(scene)
        case actionButton:
            if result == .Win{
                let scene = GameScene()
                scene.size = GameSettings.playableAreaSize
                scene.scaleMode = .AspectFit
                scene.level = LevelLoadService.sharedInstance.nextLevelByPriority(finishedLevel!.priority!)
                scene.previousScene = LevelScene()
                self.view?.presentScene(scene)
            }else{
                let scene = GameScene()
                scene.size = GameSettings.playableAreaSize
                scene.scaleMode = .AspectFit
                scene.level = LevelLoadService.sharedInstance.levelByPriority(finishedLevel!.priority!)
                scene.previousScene = LevelScene()
                self.view?.presentScene(scene)
            }
        default:
            break
        }
    }
}