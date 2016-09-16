//
//  OptionsScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 17/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class OptionsScene: SKScene,UITableViewDelegate,UITableViewDataSource{
    
    fileprivate var shakeSwitcher:UISwitch!{
        didSet{
            shakeSwitcher.isOn = GameSettings.shakeToResetEnabled
            shakeSwitcher.addTarget(self, action: #selector(switchShakeEnabled), for: .valueChanged)
        }
    }
    
    fileprivate var lockOrientationSwitcher:UISwitch!{
        didSet{
            lockOrientationSwitcher.isOn = GameSettings.lockOrientationInGameEnabled
            lockOrientationSwitcher.addTarget(self, action: #selector(switchLockOrientationEnabled), for: .valueChanged)
        }
    }
    
    fileprivate var viewScale:CGFloat = 0 // stupid  thing, I need this because view size is different than scene size
    
    var tableview : UITableView!{
        didSet{
            shakeSwitcher = UISwitch()
            lockOrientationSwitcher = UISwitch()
            tableview?.delegate = self
            tableview?.dataSource = self
            tableview?.frame = CGRect(x: 0, y: GameSettings.toolbarHeight * viewScale, width: GameSettings.playableAreaSize.width * viewScale, height: GameSettings.playableAreaSize.height * viewScale - GameSettings.toolbarHeight * viewScale)
            tableview?.estimatedRowHeight = 44
            tableview?.backgroundColor = UIColor.clear
            tableview?.allowsSelection = false
            tableview?.alwaysBounceVertical = false
            if #available(iOS 9.0, *) {
                tableview?.cellLayoutMarginsFollowReadableWidth = false
            } else {
                // Fallback on earlier versions
            }
            view?.addSubview(tableview)
        }
    }
    
    fileprivate var toolbarNode : ToolbarNode!{
        didSet{
            addChild(toolbarNode)
            toolbarNode.rightButton = toolbarNode.backButton
        }
    }
    
    var previousScene:SKScene?
    
    override func didMove(to view: SKView) {
        viewScale = self.view!.frame.size.width / GameSettings.playableAreaSize.width
        for child in children{
            child.removeFromParent()
        }
        tableview?.removeFromSuperview()
        tableview = UITableView()
        backgroundColor = UIColor.lightGray
        toolbarNode  = ToolbarNode()
        toolbarNode.centerLabelText = "Options"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        let node = atPoint(location)
        if node == toolbarNode.backButton{
            returnToPreviousScene()
        }
    }
    
    fileprivate func returnToPreviousScene(){
        tableview?.removeFromSuperview()
        let scene = previousScene ?? MenuScene()
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .fill
        view?.presentScene(scene)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ((indexPath as NSIndexPath).row){
        case 0:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Shake to reset:"
            cell.accessoryView = shakeSwitcher
            cell.backgroundColor = UIColor.clear
            return cell
        default:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Lock orientation in game:"
            cell.accessoryView = lockOrientationSwitcher
            cell.backgroundColor = UIColor.clear
            return cell
        }
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        if view != nil{
            for child in children{
                child.removeFromParent()
            }
            tableview?.removeFromSuperview()
            tableview = UITableView()
            backgroundColor = UIColor.lightGray
            toolbarNode = ToolbarNode()
            toolbarNode.centerLabelText = "Options"
        }
        
    }
    
    func switchShakeEnabled(){
        GameSettings.shakeToResetEnabled = shakeSwitcher.isOn
    }
    
    func switchLockOrientationEnabled(){
        GameSettings.lockOrientationInGameEnabled = lockOrientationSwitcher.isOn
    }
}
