//
//  ChallengeLevelScene.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 23/08/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class ChallengeLevelScene: SKScene,UITableViewDelegate,UITableViewDataSource{
    
    var levels:[Level]!
    
    fileprivate var viewScale:CGFloat = 0 // stupid  thing, I need this because view size is different than scene size
    
    var tableview : UITableView!{
        didSet{
            tableview?.delegate = self
            tableview?.dataSource = self
            tableview?.frame = CGRect(x: 0, y: GameSettings.toolbarHeight * viewScale, width: GameSettings.playableAreaSize.width * viewScale, height: GameSettings.playableAreaSize.height * viewScale - GameSettings.toolbarHeight * viewScale)
            tableview?.estimatedRowHeight = 44
            tableview?.backgroundColor = UIColor.clear
            tableview?.register(UITableViewCell.self, forCellReuseIdentifier: "levelCell")
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
        backgroundColor = UIColor.lightGray
        levels = LevelLoadService.sharedInstance.challenges
        tableview = UITableView()
        toolbarNode  = ToolbarNode()
        toolbarNode.centerLabelText = "Select Challenge"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        let node = atPoint(location)
        if node == toolbarNode.backButton{
            returnToPreviousScene()
        }
    }
    
    fileprivate func returnToPreviousScene(){
        tableview.removeFromSuperview()
        let scene = previousScene ?? MenuScene()
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .fill
        view?.presentScene(scene)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "levelCell")!
        cell.textLabel?.text = levels[(indexPath as NSIndexPath).row].name
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.removeFromSuperview()
        let scene = GameScene()
        scene.size = GameSettings.playableAreaSize
        scene.scaleMode = .fill
        scene.level = levels[(indexPath as NSIndexPath).row]
        scene.previousScene = ChallengeLevelScene()
        view!.presentScene(scene)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        if view != nil{
            toolbarNode?.removeFromParent()
            tableview?.removeFromSuperview()
            tableview = UITableView()
            backgroundColor = UIColor.lightGray
            toolbarNode = ToolbarNode()
            toolbarNode.centerLabelText = "Select Challenge"
        }
        
    }
}
