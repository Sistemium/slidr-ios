//
//  LevelScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 17/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class LevelScene: SKScene,UITableViewDelegate,UITableViewDataSource{
    
    var levels:[Level]!
    
    var tableview : UITableView!{
        didSet{
            tableview?.delegate = self
            tableview?.dataSource = self
            tableview?.frame = CGRectMake(0, GameSettings.toolbarHeight / GameSettings.playableAreaSize.height * self.view!.frame.height, self.view!.frame.width, self.view!.frame.height - GameSettings.toolbarHeight / GameSettings.playableAreaSize.height * self.view!.frame.height)
            tableview?.estimatedRowHeight = 45
            tableview?.backgroundColor = UIColor.clearColor()
            tableview?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "levelCell")
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
        levels = LevelLoadService.sharedInstance.levels
        tableview = UITableView()
        toolbarNode  = ToolbarNode()
        toolbarNode.centerLabelText = "Select level"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first!.locationInNode(self)
        let node = self.nodeAtPoint(location)
        if node == toolbarNode.backButton{
            returnToPreviousScene()
        }
    }
    
    private func returnToPreviousScene(){
        tableview.removeFromSuperview()
        let scene = previousScene ?? MenuScene()
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .Fill
        self.view?.presentScene(scene)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCellWithIdentifier("levelCell")!
        cell.textLabel?.text = levels[indexPath.row].name
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableview.removeFromSuperview()
        let scene = GameScene()
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .Fill
        scene.level = levels[indexPath.row]
        scene.previousScene = self
        self.view!.presentScene(scene)
    }

}