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
    
    private var viewScale:CGFloat = 0 // stupid  thing, I need this because view size is different than scene size
    
    var tableview : UITableView!{
        didSet{
            tableview?.delegate = self
            tableview?.dataSource = self
            tableview?.frame = CGRectMake(0, GameSettings.toolbarHeight * viewScale, GameSettings.playableAreaSize.width * viewScale, GameSettings.playableAreaSize.height * viewScale - GameSettings.toolbarHeight * viewScale)
            tableview?.estimatedRowHeight = 44
            tableview?.backgroundColor = UIColor.clearColor()
            tableview?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "levelCell")
            tableview?.alwaysBounceVertical = false
            if #available(iOS 9.0, *) {
                tableview?.cellLayoutMarginsFollowReadableWidth = false
            } else {
                // Fallback on earlier versions
            }
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
        viewScale = self.view!.frame.size.width / GameSettings.playableAreaSize.width
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
        if indexPath.row > NSUserDefaults.standardUserDefaults().valueForKey("completedLevels") as? Int ?? 0{
            cell.userInteractionEnabled = false
            cell.textLabel!.enabled = false
        }
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
    
    override func didChangeSize(oldSize: CGSize) {
        if self.view != nil{
            for child in self.children{
                child.removeFromParent()
            }
            tableview?.removeFromSuperview()
            tableview = UITableView()
            self.backgroundColor = UIColor.lightGrayColor()
            toolbarNode = ToolbarNode()
            toolbarNode.centerLabelText = "Select level"
        }
        
    }
    
}