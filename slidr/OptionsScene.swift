//
//  OptionsScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 17/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class OptionsScene: SKScene,UITableViewDelegate,UITableViewDataSource{
    
    private var shakeSwitcher:UISwitch!{
        didSet{
            shakeSwitcher.on = GameSettings.shakeToResetEnabled
            shakeSwitcher.addTarget(self, action: #selector(switchShakeEnabled), forControlEvents: .ValueChanged)
        }
    }
    
    private var lockOrientationSwitcher:UISwitch!{
        didSet{
            lockOrientationSwitcher.on = GameSettings.lockOrientationInGameEnabled
            shakeSwitcher.addTarget(self, action: #selector(switchLockOrientationEnabled), forControlEvents: .ValueChanged)
        }
    }
    
    private var viewScale:CGFloat = 0 // stupid  thing, I need this because view size is different than scene size
    
    var tableview : UITableView!{
        didSet{
            shakeSwitcher = UISwitch()
            lockOrientationSwitcher = UISwitch()
            tableview?.delegate = self
            tableview?.dataSource = self
            tableview?.frame = CGRectMake(0, GameSettings.toolbarHeight * viewScale, GameSettings.playableAreaSize.width * viewScale, GameSettings.playableAreaSize.height * viewScale - GameSettings.toolbarHeight * viewScale)
            tableview?.estimatedRowHeight = 44
            tableview?.backgroundColor = UIColor.clearColor()
            tableview?.allowsSelection = false
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
        for child in self.children{
            child.removeFromParent()
        }
        tableview?.removeFromSuperview()
        tableview = UITableView()
        self.backgroundColor = UIColor.lightGrayColor()
        toolbarNode  = ToolbarNode()
        toolbarNode.centerLabelText = "Options"
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
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.row){
        case 0:
            let cell =  NSBundle.mainBundle().loadNibNamed("GameSpeedSliderTableViewCell", owner: self, options: nil)[0] as! GameSpeedSliderTableViewCell
            cell.backgroundColor = UIColor.clearColor()
            return cell
        case 1:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Shake to reset:"
            cell.accessoryView = shakeSwitcher
            cell.backgroundColor = UIColor.clearColor()
            return cell
        default:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Lock orientation in game:"
            cell.accessoryView = lockOrientationSwitcher
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
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
            toolbarNode.centerLabelText = "Options"
        }
        
    }
    
    func switchShakeEnabled(){
        GameSettings.shakeToResetEnabled = shakeSwitcher.on
    }
    
    func switchLockOrientationEnabled(){
        GameSettings.lockOrientationInGameEnabled = lockOrientationSwitcher.on
    }
}