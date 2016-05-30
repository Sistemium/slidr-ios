//
//  OptionsScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 17/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class OptionsScene: SKScene,UITableViewDelegate,UITableViewDataSource{
    
    var tableview : UITableView!{
        didSet{
            tableview?.delegate = self
            tableview?.dataSource = self
            tableview?.frame = CGRectMake(0, GameSettings.toolbarHeight / GameSettings.playableAreaSize.height * self.view!.frame.height, self.view!.frame.width, self.view!.frame.height - GameSettings.toolbarHeight / GameSettings.playableAreaSize.height * self.view!.frame.height)
            tableview?.estimatedRowHeight = 45
            tableview?.backgroundColor = UIColor.clearColor()
            tableview?.allowsSelection = false
            self.view?.addSubview(tableview)
        }
    }
    
    private var toolbarNode : ToolbarNode!{
        didSet{
            self.addChild(toolbarNode)
        }
    }
    
    var previousScene:SKScene?
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.lightGrayColor()
        tableview = UITableView()
        toolbarNode  = ToolbarNode()
        toolbarNode.timerLabelText = "Options"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first!.locationInNode(self)
        let node = self.nodeAtPoint(location)
        if node == toolbarNode.backButton{
            returnToPreviousScene()
        }
    }
    
    private func returnToPreviousScene(){
        tableview?.removeFromSuperview()
        let scene = previousScene ?? MenuScene()
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .Fill
        self.view?.presentScene(scene)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =  NSBundle.mainBundle().loadNibNamed("OptionsTableViewCell", owner: self, options: nil)[0] as! OptionsTableViewCell
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
}