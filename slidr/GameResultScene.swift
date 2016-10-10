//
//  GameResultScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 20/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

enum Result{
    case win,lose
}

class GameResultScene: SKScene{
    
    var scoreTime:CFTimeInterval?
    
    var scorePercent:Int?
    
    var result:Result = Result.win
    
    var finishedLevel :Level?
    
    var infoText = ""
    
    fileprivate var resultLabel: OutlineSKLabelNode!{
        didSet{
            resultLabel.text = result == .win ? "You Win" : "You Lose"
            resultLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 + GameSettings.labelSize * 1.3)
            resultLabel.fontSize = GameSettings.labelSize
            resultLabel.zPosition = 1.0
            resultLabel.fontColor = result == .win ? UIColor.green : UIColor.red
            addChild(resultLabel)
            addChild(resultLabel.outlineLabel)
        }
    }
    
    fileprivate var questionLabel: OutlineSKLabelNode!{
        didSet{
            questionLabel.text = result == .win ? "Play next level?" : "Play again?"
            questionLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2)
            questionLabel.fontSize = GameSettings.labelSize
            questionLabel.zPosition = 1.0
            questionLabel.fontColor = UIColor.white
            addChild(questionLabel)
            addChild(questionLabel.outlineLabel)
        }
    }
    
    fileprivate var returnButton: OutlineSKLabelNode!{
        didSet{
            returnButton.text = "No"
            returnButton.position = CGPoint(x: GameSettings.playableAreaSize.width/2 - GameSettings.labelSize * 1.3, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 1.3)
            returnButton.fontSize = GameSettings.labelSize
            returnButton.zPosition = 1.0
            returnButton.fontColor = UIColor.white
            addChild(returnButton)
            addChild(returnButton.outlineLabel)
        }
    }
    
    fileprivate var actionButton: OutlineSKLabelNode!{
        didSet{
            actionButton.text = "Yes"
            actionButton.position = CGPoint(x: GameSettings.playableAreaSize.width/2 + GameSettings.labelSize * 1.3, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 1.3)
            actionButton.fontSize = GameSettings.labelSize
            actionButton.zPosition = 1.0
            actionButton.fontColor = UIColor.white
            addChild(actionButton)
            addChild(actionButton.outlineLabel)
        }
    }
    
    fileprivate var scoreLabel: OutlineSKLabelNode!{
        didSet{
            scoreLabel.text = scoreTime == nil ? "" : "You survived \(scoreTime!.fixedFractionDigits(0)) second"
            if scoreTime != nil && scoreTime != 1.0 {
                scoreLabel.text! += "s"
            }
            scoreLabel.text = scorePercent == nil ? "" : "You compleded \(scorePercent!) %"
            scoreLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 2.4)
            scoreLabel.fontSize = GameSettings.labelSize * 0.5
            scoreLabel.zPosition = 1.0
            scoreLabel.fontColor = UIColor.black
            addChild(scoreLabel)
        }
    }
    
    fileprivate var recordLabel: OutlineSKLabelNode!{
        didSet{
            if scoreTime != nil{
                let record = UserDefaults.standard.integer(forKey: "recordTime")
                if record < Int(scoreTime!){
                    recordLabel.text = "It's your new record!"
                    UserDefaults.standard.setValue(Int(scoreTime!), forKey: "recordTime")
                }else{
                    recordLabel.text = "Your best time was \(record) second"
                    if scoreTime != nil && record != 1 {
                        recordLabel.text! += "s"
                    }
                }
            }
            if scorePercent != nil{
                let record = UserDefaults.standard.integer(forKey: "recordPercent\(finishedLevel?.name)")
                if record < Int(scorePercent!){
                    recordLabel.text = "It's your new record!"
                    UserDefaults.standard.setValue(Int(scorePercent!), forKey: "recordPercent\(finishedLevel?.name)")
                }else{
                    recordLabel.text = "Your best result was \(record) %"
                }
            }
            recordLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 - GameSettings.labelSize * 3.5)
            recordLabel.fontSize = GameSettings.labelSize * 0.5
            recordLabel.zPosition = 1.0
            recordLabel.fontColor = UIColor.black
            addChild(recordLabel)
        }
    }
    
    fileprivate var infoLabel: OutlineSKLabelNode!{
        didSet{
            infoLabel.text = infoText
            infoLabel.position = CGPoint(x: GameSettings.playableAreaSize.width/2, y: GameSettings.playableAreaSize.height/2 + GameSettings.labelSize * 2.6)
            infoLabel.fontSize = GameSettings.labelSize * 0.5
            infoLabel.zPosition = 1.0
            infoLabel.fontColor = UIColor.black
            addChild(infoLabel)
            addChild(infoLabel.outlineLabel)
        }
    }
    
    override func didMove(to view: SKView) {
        for child in children{
            child.removeFromParent()
        }
        backgroundColor = UIColor.lightGray
        resultLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        questionLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        returnButton = OutlineSKLabelNode(fontNamed:"Chalkduster")
        actionButton = OutlineSKLabelNode(fontNamed:"Chalkduster")
        scoreLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        recordLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        infoLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        if result == .win{
            LevelLoadService.sharedInstance.updateCompletedLevelsByPriority(finishedLevel!.priority!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        let node = atPoint(location)
        switch node {
        case returnButton:
            if finishedLevel != nil {
                if finishedLevel?.type == .Puzzle{
                    let scene = LevelScene()
                    scene.size = GameSettings.playableAreaSize
                    scene.scaleMode = .fill
                    scene.previousScene = MenuScene()
                    view!.presentScene(scene)
                }else{
                    let scene = ChallengeLevelScene()
                    scene.size = GameSettings.playableAreaSize
                    scene.scaleMode = .fill
                    scene.previousScene = MenuScene()
                    view!.presentScene(scene)
                }
            }else{
                let scene = MenuScene()
                scene.size = GameSettings.playableAreaSize
                scene.scaleMode = .fill
                view!.presentScene(scene)
            }
        case actionButton:
            if finishedLevel?.type == .Challenge{
                if result == .win{
                    let scene = GameScene()
                    scene.size = GameSettings.playableAreaSize
                    scene.scaleMode = .fill
                    scene.level = LevelLoadService.sharedInstance.nextChallengeByPriority(finishedLevel!.priority!)
                    scene.previousScene = ChallengeLevelScene()
                    view?.presentScene(scene)
                }else{
                    let scene = GameScene()
                    scene.size = GameSettings.playableAreaSize
                    scene.scaleMode = .fill
                    scene.level = LevelLoadService.sharedInstance.challengeByPriority(finishedLevel!.priority!)
                    scene.previousScene = ChallengeLevelScene()
                    view?.presentScene(scene)
                }
            }
            else if result == .win{
                let scene = GameScene()
                scene.size = GameSettings.playableAreaSize
                scene.scaleMode = .fill
                scene.level = LevelLoadService.sharedInstance.nextLevelByPriority(finishedLevel!.priority!)
                scene.previousScene = LevelScene()
                view?.presentScene(scene)
            }else{
                let scene = GameScene()
                scene.size = GameSettings.playableAreaSize
                scene.scaleMode = .fill
                if finishedLevel != nil {
                    scene.level = LevelLoadService.sharedInstance.levelByPriority(finishedLevel!.priority!)
                    scene.previousScene = LevelScene()
                }else{
                    scene.previousScene = MenuScene()
                }
                view?.presentScene(scene)
            }
        default:
            break
        }
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        for child in children{
            child.removeFromParent()
        }
        backgroundColor = UIColor.lightGray
        resultLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        questionLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        returnButton = OutlineSKLabelNode(fontNamed:"Chalkduster")
        actionButton = OutlineSKLabelNode(fontNamed:"Chalkduster")
        scoreLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        recordLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
        infoLabel = OutlineSKLabelNode(fontNamed:"Chalkduster")
    }
}
