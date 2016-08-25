//
//  GameViewController.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 03/05/16.
//  Copyright (c) 2016 Edgar Jan Vuicik. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = view as! SKView
        if max(UIScreen.mainScreen().bounds.height,UIScreen.mainScreen().bounds.width) / min(UIScreen.mainScreen().bounds.width,UIScreen.mainScreen().bounds.height) > 1.5{
            GameSettings.playableAreaSize = CGSize(width: 768.375, height: 1366)
        }else if UIScreen.mainScreen().bounds.height / UIScreen.mainScreen().bounds.width < 1.5{
            GameSettings.playableAreaSize = CGSize(width: 1024.5, height: 1366)
        } else{
            GameSettings.playableAreaSize = CGSize(width: 910.666, height: 1366)
        }
        if !UIApplication.sharedApplication().statusBarOrientation.isPortrait{
            GameSettings.playableAreaSize = GameSettings.playableAreaSize.reversed()
        }
        GameSettings.rezolutionNormalizationValue = max(UIScreen.mainScreen().bounds.height,UIScreen.mainScreen().bounds.width) / 1366
        let scene = MenuScene()
        scene.size = GameSettings.playableAreaSize
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .Fill
        skView.showsFPS = true
        skView.presentScene(scene)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        let skView = view as! SKView
        if (skView.scene!.dynamicType == GameScene.self || skView.scene! is GameResultScene) && GameSettings.lockOrientationInGameEnabled{
            return false
        }
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown, .LandscapeRight, .LandscapeLeft]
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            if GameSettings.shakeToResetEnabled{
                resetLevel()
            }
        }
    }
    
    func resetLevel(){
        let skView = view as! SKView
        if let game = skView.scene as? GameScene{
            if game.gameMode == .Level{
                game.timeSinceLastUpdate = nil
                game.timeToNextBlockPush = GameSettings.pushBlockInterval
                for node in game.children{
                    if let block = node as? Block{
                        block.removeFromParent()
                    }
                }
                if let _ = game.level{
                    game.level = LevelLoadService.sharedInstance.levelByPriority(game.level!.priority!)
                }
            }
        }
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition(nil, completion:
            {_ in
                NSNotificationCenter.defaultCenter().postNotificationName("RotationEnded", object: nil)
        })
        if size.width > size.height && GameSettings.playableAreaSize.width < GameSettings.playableAreaSize.height || size.width < size.height && GameSettings.playableAreaSize.width > GameSettings.playableAreaSize.height{
            GameSettings.playableAreaSize = GameSettings.playableAreaSize.reversed()
        }
        let skView = view as! SKView
        skView.scene!.size = GameSettings.playableAreaSize
    }
    
}