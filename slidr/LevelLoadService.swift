//
//  LevelLoadService.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 19/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import Foundation

class LevelLoadService{
    static let sharedInstance = LevelLoadService()
    
    var levels : [Level]{
        get{
            return loadLevels()
        }
    }
    
    private init() {
    }
    
    private func loadLevels() -> [Level]{
        var levels = [Level]()
        let fileManager = NSFileManager.defaultManager()
        let enumerator = fileManager.enumeratorAtPath(NSBundle.mainBundle().bundlePath)
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".plist") && element.hasPrefix("Level") {
                levels.append(readPropertyList(element.substringToIndex(element.characters.indexOf(".")!)))
            }
        }
        levels.sortInPlace({ $0.priority < $1.priority })
        return levels
    }
    
    private func readPropertyList(plist:String) ->Level{
        var format = NSPropertyListFormat.XMLFormat_v1_0
        var plistData:[String:AnyObject] = [:]
        let plistPath:String? = NSBundle.mainBundle().pathForResource(plist, ofType: "plist")!
        let plistXML = NSFileManager.defaultManager().contentsAtPath(plistPath!)!
        plistData = try! NSPropertyListSerialization.propertyListWithData(plistXML,options: .MutableContainersAndLeaves,format: &format) as! [String:AnyObject]
        let level = Level()
        level.name = plistData["name"] as? String
        level.priority = plistData["priority"] as? Float
        level.timeout = plistData["timeout"] as! Double * (Double(GameSettings.defaultSpeed) / Double(GameSettings.baseSpeed))
        for element in plistData["blocks"] as! NSArray{
            let blockData = element as! NSDictionary
            level.blocks.append(Block(blockData: blockData))
        }
        return level
    }
    
    func levelByPriority(priority:Float)->Level?{
        for level in levels{
            if level.priority == priority{
                return level
            }
        }
        return nil
    }
    
    func nextLevelByPriority(priority:Float)->Level?{
        for level in levels{
            if level.priority > priority{
                return level
            }
        }
        return nil
    }
}