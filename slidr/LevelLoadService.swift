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
    
    var challenges : [Level]{
        get{
            return loadChallenges()
        }
    }
    
    private init() {
    }
    
    private func loadLevels() -> [Level]{
        var levels = [Level]()
        let fileManager = NSFileManager.defaultManager()
        let enumerator = fileManager.enumeratorAtPath(NSBundle.mainBundle().bundlePath)
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".json") && element.hasPrefix("Level"){
                levels.append(readJson(element.substringToIndex(element.characters.indexOf(".")!)))
            }
        }
        levels.sortInPlace({ $0.priority < $1.priority })
        return levels
    }
    
    private func loadChallenges() -> [Level]{
        var challenges = [Level]()
        let fileManager = NSFileManager.defaultManager()
        let enumerator = fileManager.enumeratorAtPath(NSBundle.mainBundle().bundlePath)
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".json") && element.hasPrefix("Challenge"){
                challenges.append(readJson(element.substringToIndex(element.characters.indexOf(".")!)))
            }
        }
        challenges.sortInPlace({ $0.priority < $1.priority })
        return challenges
    }
    
    private func readJson(json:String) ->Level{
        let jsonPath:String? = NSBundle.mainBundle().pathForResource(json, ofType: "json")!
        let jsonData = try? NSData(contentsOfFile: jsonPath!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        let jsonResult: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        var level = Level()
        level.name = jsonResult["name"] as? String
        level.priority = jsonResult["priority"] as? Float
        level.timeout = jsonResult["timeout"] as! Double * (Double(GameSettings.defaultSpeed) / Double(GameSettings.defaultSpeed))
        level.type = LevelType(rawValue: jsonResult["type"] as! String)
        if jsonResult["completionTime"] != nil{
            level.completionTime = jsonResult["completionTime"] as! Double * (Double(GameSettings.defaultSpeed) / Double(GameSettings.defaultSpeed))
        }
        for element in jsonResult["blocks"] as! NSArray{
            let blockData = element as! NSDictionary
            level.blocks.append(Block(blockData: blockData))
        }
        return level
    }
    
    func updateCompletedLevelsByPriority(priority:Float){
        if Int(priority) > GameSettings.completedLevels{
            GameSettings.completedLevels = Int(priority)
        }
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
    
    func challengeByPriority(priority:Float)->Level?{
        for level in challenges{
            if level.priority == priority{
                return level
            }
        }
        return nil
    }
    
    func nextChallengeByPriority(priority:Float)->Level?{
        for level in challenges{
            if level.priority > priority{
                return level
            }
        }
        return nil
    }
}