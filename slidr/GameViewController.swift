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
        let scene = MenuScene()
        let skView = self.view as! SKView
        if UIScreen.mainScreen().bounds.height / UIScreen.mainScreen().bounds.width > 1.5{
            GameSettings.playableAreaSize = CGSize(width: 768.375, height: 1366)
        }else if UIScreen.mainScreen().bounds.height / UIScreen.mainScreen().bounds.width < 1.5{
            GameSettings.playableAreaSize = CGSize(width: 1024.5, height: 1366)
        } else{
            GameSettings.playableAreaSize = CGSize(width: 910.666, height: 1366)
        }
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
        return .Portrait
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            resetLevel()
        }
    }
    
    func resetLevel(){
        let skView = self.view as! SKView
        if let game = skView.scene as? GameScene{
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