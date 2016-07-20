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
    
    private var resultLabel: OutlineSKLabelNode!{
        didSet{
            resultLabel.text = result == .Win ? "You Win" : "You Lose"
            resultLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 + GameSettings.labelSize * 1.3)
            resultLabel.fontSize = GameSettings.labelSize
            resultLabel.zPosition = 3.0
            resultLabel.fontColor = result == .Win ? UIColor.greenColor() : UIColor.redColor()
            self.addChild(resultLabel)
            self.addChild(resultLabel.outlineLabel)
        }
    }
    
    private var questionLabel: OutlineSKLabelNode!{
        didSet{
            questionLabel.text = result == .Win ? "Play next level?" : "Play again?"
            questionLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2)
            questionLabel.fontSize = GameSettings.labelSize
            questionLabel.zPosition = 3.0
            questionLabel.fontColor = UIColor.whiteColor()
            self.addChild(questionLabel)
            self.addChild(questionLabel.outlineLabel)
        }
    }
    
    private var returnButton: OutlineSKLabelNode!{
        didSet{
            returnButton.text = "No"
            returnButton.position = CGPoint(x: GameSettings.playableAreaSize.width/2 - GameSettings.labelSize * 1.3, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 1.3)
            returnButton.fontSize = GameSettings.labelSize
            returnButton.zPosition = 3.0
            returnButton.fontColor = UIColor.whiteColor()
            self.addChild(returnButton)
            self.addChild(returnButton.outlineLabel)
        }
    }
    
    private var actionButton: OutlineSKLabelNode!{
        didSet{
            actionButton.text = "Yes"
            actionButton.position = CGPoint(x: GameSettings.playableAreaSize.width/2 + GameSettings.labelSize * 1.3, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 1.3)
            actionButton.fontSize = GameSettings.labelSize
            actionButton.zPosition = 3.0
            actionButton.fontColor = UIColor.whiteColor()
            self.addChild(actionButton)
            self.addChild(actionButton.outlineLabel)
        }
    }
    
    private var scoreLabel: OutlineSKLabelNode!{
        didSet{
            scoreLabel.text = scoreTime == nil ? "" : "You survived \(scoreTime!.fixedFractionDigits(0)) second"
            if scoreTime != nil && scoreTime != 1.0 {
                scoreLabel.text! += "s"
            }
            scoreLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 2.4)
            scoreLabel.fontSize = GameSettings.labelSize * 0.5
            scoreLabel.zPosition = 3.0
            scoreLabel.fontColor = UIColor.blackColor()
            self.addChild(scoreLabel)
            self.addChild(scoreLabel.outlineLabel)
        }
    }
    
    private var recordLabel: OutlineSKLabelNode!{
        didSet{
            if scoreTime != nil{
                let record = NSUserDefaults.standardUserDefaults().integerForKey("record")
                if record < Int(scoreTime!){
                    recordLabel.text = "It's your new record!"
                    NSUserDefaults.standardUserDefaults().setValue(Int(scoreTime!), forKey: "record")
                }else{
                    recordLabel.text = "Your best time was \(record) second"
                    if scoreTime != nil && recordLabel != 1.0 {
                        recordLabel.text! += "s"
                    }
                }
            }
            recordLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 3.5)
            recordLabel.fontSize = GameSettings.labelSize * 0.5
            recordLabel.zPosition = 3.0
            recordLabel.fontColor = UIColor.blackColor()
            addChild(recordLabel)
            addChild(recordLabel.outlineLabel)
        }
    }
    
    private var infoLabel: OutlineSKLabelNode!{
        didSet{
            infoLabel.text = infoText
            infoLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 + GameSettings.labelSize * 2.6)
            infoLabel.fontSize = GameSettings.labelSize * 0.5
            infoLabel.zPosition = 3.0
            infoLabel.fontColor = UIColor.blackColor()
            self.addChild(infoLabel)
            self.addChild(infoLabel.outlineLabel)
        }
    }
    
    override func didMoveToView(view: SKView) {
        for child in self.children{
            child.removeFromParent()
        }
        self.backgroundColor = UIColor.lightGrayColor()
        resultLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        questionLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        returnButton = OutlineSKLabelNode(fontNamed:"Chalkduster")
        actionButton = OutlineSKLabelNode(fontNamed:"Chalkduster")
        scoreLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        recordLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        infoLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
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
        resultLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        questionLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        returnButton = OutlineSKLabelNode(fontNamed:"Chalkduster")
        actionButton = OutlineSKLabelNode(fontNamed:"Chalkduster")
        scoreLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        recordLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        infoLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
    }
}