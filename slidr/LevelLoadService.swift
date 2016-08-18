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
            if element.hasSuffix(".json"){
                levels.append(readJson(element.substringToIndex(element.characters.indexOf(".")!)))
            }
        }
        levels.sortInPlace({ $0.priority < $1.priority })
        return levels
    }
    
    private func readJson(json:String) ->Level{
        let jsonPath:String? = NSBundle.mainBundle().pathForResource(json, ofType: "json")!
        let jsonData = try? NSData(contentsOfFile: jsonPath!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        let jsonResult: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        var level = Level()
        level.name = jsonResult["name"] as? String
        level.priority = jsonResult["priority"] as? Float
        level.timeout = jsonResult["timeout"] as! Double * (Double(GameSettings.defaultSpeed) / Double(GameSettings.baseSpeed))
        for element in jsonResult["blocks"] as! NSArray{
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
        if Int(priority) > GameSettings.completedLevels{
            GameSettings.completedLevels = Int(priority)
        }
        for level in levels{
            if level.priority > priority{
                return level
            }
        }
        return nil
    }
}