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
        scene.size = UIScreen.mainScreen().bounds.size
        GameSettings.playableAreaSize = scene.size
//            skView.showsFPS = true
//            skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFit
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
}