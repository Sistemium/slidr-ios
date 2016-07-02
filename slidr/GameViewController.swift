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
        let skView = self.view as! SKView
        if UIScreen.mainScreen().bounds.height / UIScreen.mainScreen().bounds.width > 1.5{
            GameSettings.playableAreaSize = CGSize(width: 768.375, height: 1366)
        }else if UIScreen.mainScreen().bounds.height / UIScreen.mainScreen().bounds.width < 1.5{
            GameSettings.playableAreaSize = CGSize(width: 1024.5, height: 1366)
        } else{
            GameSettings.playableAreaSize = CGSize(width: 910.666, height: 1366)
        }
        if !UIApplication.sharedApplication().statusBarOrientation.isPortrait{
            GameSettings.playableAreaSize = GameSettings.playableAreaSize.reversed()
        }
        let scene = MenuScene()
        scene.size = GameSettings.playableAreaSize
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .Fill
        skView.presentScene(scene)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
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
        let skView = self.view as! SKView
        if let game = skView.scene as? GameScene{
            if game.gameMode == .Level{
                game.destroyedCount = 0
                game.leftCount = 0
                game.timeSinceLastUpdate = nil
                game.timeToNextBlockPush = GameSettings.pushBlockInterval
                game.pushedCount = 0
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
        GameSettings.playableAreaSize = GameSettings.playableAreaSize.reversed()
        let skView = self.view as! SKView
        skView.scene!.size = GameSettings.playableAreaSize
    }

}