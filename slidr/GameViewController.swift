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

        if let scene = GameScene(fileNamed:"GameScene") {
            let skView = self.view as! SKView
            GameSettings.playableAreaSize = skView.frame.size
            GameSettings.grid.height *=  GameSettings.playableAreaSize.height / GameSettings.playableAreaSize.width
            GameSettings.playableAreaSize.height = CGFloat(Int(GameSettings.grid.height)) / GameSettings.grid.width * GameSettings.playableAreaSize.width
            GameSettings.grid.height = CGFloat(Int(GameSettings.grid.height))
            scene.size = GameSettings.playableAreaSize
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .AspectFit
            skView.presentScene(scene)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
