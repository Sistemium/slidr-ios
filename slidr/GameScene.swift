//
//  GameScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 03/05/16.
//  Copyright (c) 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    private var timeSinceLastUpdate:CFTimeInterval?
    private var timeToNextBlockPush = 1.0
    
    override func didMoveToView(view: SKView) {
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

    }
   
    override func update(currentTime: CFTimeInterval) {
        if let oldTime = self.timeSinceLastUpdate{
            timeToNextBlockPush -= currentTime - oldTime
            if timeToNextBlockPush < 0 {
                timeToNextBlockPush += GameSettings.pushBlockInterval
                self.addChild(Block())
            }
        }
        for node in self.children{
            if let block = node as? Block{
                block.physicsBody?.velocity = block.pushVector
            }
        }
        self.timeSinceLastUpdate = currentTime
    }
    
}
