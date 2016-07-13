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
    
    var scoreTime:CFTimeInterval?
    
    var result:Result = Result.Win
    
    var finishedLevel :Level?
    
    var infoText = ""
    
    private var resultLabel: SKLabelNode!{
        didSet{
            self.addChild(resultLabel)
            resultLabel.text = result == .Win ? "You Win" : "You Lose"
            resultLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 + GameSettings.labelSize * 1.3)
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
            returnButton.position = CGPoint(x: GameSettings.playableAreaSize.width/2 - GameSettings.labelSize * 1.3, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 1.3)
            returnButton.fontSize = GameSettings.labelSize
            returnButton.zPosition = 3.0
            returnButton.fontColor = UIColor.whiteColor()
        }
    }
    
    private var actionButton: SKLabelNode!{
        didSet{
            self.addChild(actionButton)
            actionButton.text = "Yes"
            actionButton.position = CGPoint(x: GameSettings.playableAreaSize.width/2 + GameSettings.labelSize * 1.3, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 1.3)
            actionButton.fontSize = GameSettings.labelSize
            actionButton.zPosition = 3.0
            actionButton.fontColor = UIColor.whiteColor()
        }
    }
    
    private var scoreLabel: SKLabelNode!{
        didSet{
            self.addChild(scoreLabel)
            scoreLabel.text = scoreTime == nil ? "" : "You survived \(scoreTime!.fixedFractionDigits(0)) second"
            if scoreTime != 1.0 {
                scoreLabel.text! += "s"
            }
            scoreLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 2.4)
            scoreLabel.fontSize = GameSettings.labelSize * 0.5
            scoreLabel.zPosition = 3.0
            scoreLabel.fontColor = UIColor.blackColor()
        }
    }
    
    private var recordLabel: SKLabelNode!{
        didSet{
            self.addChild(recordLabel)
            if scoreTime != nil{
                let record = NSUserDefaults.standardUserDefaults().integerForKey("record")
                if record < Int(scoreTime!){
                    recordLabel.text = "It is your new record!"
                    NSUserDefaults.standardUserDefaults().setValue(Int(scoreTime!), forKey: "record")
                }else{
                    recordLabel.text = "Your best time was \(record) second"
                    if recordLabel != 1.0 {
                        recordLabel.text! += "s"
                    }
                }
            }
            recordLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 3.5)
            recordLabel.fontSize = GameSettings.labelSize * 0.5
            recordLabel.zPosition = 3.0
            recordLabel.fontColor = UIColor.blackColor()
        }
    }
    
    private var infoLabel: SKLabelNode!{
        didSet{
            self.addChild(infoLabel)
            infoLabel.text = infoText
            infoLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 + GameSettings.labelSize * 2.6)
            infoLabel.fontSize = GameSettings.labelSize * 0.5
            infoLabel.zPosition = 3.0
            infoLabel.fontColor = UIColor.blackColor()
        }
    }
    
    override func didMoveToView(view: SKView) {
        for child in self.children{
            child.removeFromParent()
        }
        self.backgroundColor = UIColor.lightGrayColor()
        resultLabel = SKLabelNode(fontNamed:"Chalkduster")
        questionLabel = SKLabelNode(fontNamed:"Chalkduster")
        returnButton = SKLabelNode(fontNamed:"Chalkduster")
        actionButton = SKLabelNode(fontNamed:"Chalkduster")
        scoreLabel = SKLabelNode(fontNamed:"Chalkduster")
        recordLabel = SKLabelNode(fontNamed:"Chalkduster")
        infoLabel = SKLabelNode(fontNamed:"Chalkduster")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first!.locationInNode(self)
        let node = self.nodeAtPoint(location)
        switch node {
        case returnButton:
            if finishedLevel != nil {
                let scene = LevelScene()
                scene.size = GameSettings.playableAreaSize
                scene.scaleMode = .Fill
                scene.previousScene = MenuScene()
                self.view!.presentScene(scene)
            }else{
                let scene = MenuScene()
                scene.size = GameSettings.playableAreaSize
                scene.scaleMode = .Fill
                self.view!.presentScene(scene)
            }
        case actionButton:
            if result == .Win{
                let scene = GameScene()
                scene.size = GameSettings.playableAreaSize
                scene.scaleMode = .Fill
                scene.level = LevelLoadService.sharedInstance.nextLevelByPriority(finishedLevel!.priority!)
                scene.previousScene = LevelScene()
                self.view?.presentScene(scene)
            }else{
                let scene = GameScene()
                scene.size = GameSettings.playableAreaSize
                scene.scaleMode = .Fill
                if finishedLevel != nil {
                    scene.level = LevelLoadService.sharedInstance.levelByPriority(finishedLevel!.priority!)
                    scene.previousScene = LevelScene()
                }else{
                    scene.previousScene = MenuScene()
                }
                self.view?.presentScene(scene)
            }
        default:
            break
        }
    }
    
    override func didChangeSize(oldSize: CGSize) {
        for child in self.children{
            child.removeFromParent()
        }
        self.backgroundColor = UIColor.lightGrayColor()
        resultLabel = SKLabelNode(fontNamed:"Chalkduster")
        questionLabel = SKLabelNode(fontNamed:"Chalkduster")
        returnButton = SKLabelNode(fontNamed:"Chalkduster")
        actionButton = SKLabelNode(fontNamed:"Chalkduster")
        scoreLabel = SKLabelNode(fontNamed:"Chalkduster")
        recordLabel = SKLabelNode(fontNamed:"Chalkduster")
        infoLabel = SKLabelNode(fontNamed:"Chalkduster")
    }
}