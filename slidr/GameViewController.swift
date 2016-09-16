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
        if max(UIScreen.main.bounds.height,UIScreen.main.bounds.width) / min(UIScreen.main.bounds.width,UIScreen.main.bounds.height) > 1.5{
            GameSettings.playableAreaSize = CGSize(width: 768.375, height: 1366)
        }else if UIScreen.main.bounds.height / UIScreen.main.bounds.width < 1.5{
            GameSettings.playableAreaSize = CGSize(width: 1024.5, height: 1366)
        } else{
            GameSettings.playableAreaSize = CGSize(width: 910.666, height: 1366)
        }
        if !UIApplication.shared.statusBarOrientation.isPortrait{
            GameSettings.playableAreaSize = GameSettings.playableAreaSize.reversed()
        }
        GameSettings.rezolutionNormalizationValue = max(UIScreen.main.bounds.height,UIScreen.main.bounds.width) / 1366
        let scene = MenuScene()
        scene.size = GameSettings.playableAreaSize
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .fill
        skView.showsFPS = true
        skView.presentScene(scene)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var shouldAutorotate : Bool {
        let skView = view as! SKView
        if (type(of: skView.scene!) == GameScene.self || skView.scene! is GameResultScene) && GameSettings.lockOrientationInGameEnabled{
            return false
        }
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown, .landscapeRight, .landscapeLeft]
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if GameSettings.shakeToResetEnabled{
                resetLevel()
            }
        }
    }
    
    func resetLevel(){
        let skView = view as! SKView
        if let game = skView.scene as? GameScene{
            if game.gameMode == .level || game.gameMode == .challenge{
                game.timeSinceLastUpdate = nil
                game.timeToNextBlockPush = GameSettings.pushBlockInterval
                for node in game.children{
                    if let block = node as? Block{
                        block.removeFromParent()
                    }
                }
                game.startTime = nil
                if game.level?.type == .Puzzle{
                    game.level = LevelLoadService.sharedInstance.levelByPriority(game.level!.priority!)
                }
                if game.level?.type == .Challenge{
                    
                    game.level = LevelLoadService.sharedInstance.challengeByPriority(game.level!.priority!)
                }
            }
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion:
            {_ in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "RotationEnded"), object: nil)
        })
        if size.width > size.height && GameSettings.playableAreaSize.width < GameSettings.playableAreaSize.height || size.width < size.height && GameSettings.playableAreaSize.width > GameSettings.playableAreaSize.height{
            GameSettings.playableAreaSize = GameSettings.playableAreaSize.reversed()
        }
        let skView = view as! SKView
        skView.scene!.size = GameSettings.playableAreaSize
    }
    
}
