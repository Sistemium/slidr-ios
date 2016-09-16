//
//  LevelLoadService.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 19/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    
    fileprivate init() {
    }
    
    fileprivate func loadLevels() -> [Level]{
        var levels = [Level]()
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: Bundle.main.bundlePath)
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".json") && element.hasPrefix("Level"){
                levels.append(readJson(element.substring(to: element.characters.index(of: ".")!)))
            }
        }
        levels.sort(by: { $0.priority < $1.priority })
        return levels
    }
    
    fileprivate func loadChallenges() -> [Level]{
        var challenges = [Level]()
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: Bundle.main.bundlePath)
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".json") && element.hasPrefix("Challenge"){
                challenges.append(readJson(element.substring(to: element.characters.index(of: ".")!)))
            }
        }
        challenges.sort(by: { $0.priority < $1.priority })
        return challenges
    }
    
    fileprivate func readJson(_ json:String) ->Level{
        let jsonPath:String? = Bundle.main.path(forResource: json, ofType: "json")!
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath!), options: NSData.ReadingOptions.mappedIfSafe)
        let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        var level = Level()
        level.name = jsonResult["name"] as? String
        level.priority = jsonResult["priority"] as? Float
        level.timeout = jsonResult["timeout"] as! Double * (Double(GameSettings.defaultSpeed) / Double(GameSettings.defaultSpeed))
        level.type = LevelType(rawValue: jsonResult["type"] as! String)
        if jsonResult["completionTime"] != nil{
            level.completionTime = jsonResult["completionTime"] as! Double * (Double(GameSettings.defaultSpeed) / Double(GameSettings.defaultSpeed))
        }
        if let blocks = jsonResult["blocks"] as? NSArray{
            for element in blocks{
                let blockData = element as! NSDictionary
                level.blocks.append(Block(blockData: blockData))
            }
        }
        
        if let scenarioArray = jsonResult["scenario"] as? NSArray{
            for scen in scenarioArray{
                if let scenario = scen as? NSDictionary{
                    let numberOfBlocks = scenario["numberOfBlocks"] as! Int
                    for i in 0..<numberOfBlocks{
                        let blockData = NSMutableDictionary()
                        blockData["type"] = scenario["type"]
                        blockData["pushTime"] = Double(i) * (scenario["pushTimeInterval"] as! Double)
                        blockData["speedModifier"] = 1 + Double(i) * (scenario["speedIncreasingInterval"] as! Double)
                        blockData["width"] = (scenario["size"] as! NSDictionary)["width"]
                        blockData["height"] = (scenario["size"] as! NSDictionary)["height"]
                        for j in scenario["position"] as! NSArray{
                            if let position = j as? NSDictionary{
                                if i < position["indexes"] as! Int{
                                    blockData["positionX"] = position["x"]
                                    blockData["positionY"] = position["y"]
                                    switch (blockData["positionX"] as! Double,blockData["positionY"] as! Double) {
                                    case let (_,y) where y<0:
                                        blockData["pushVectorX"] = 0
                                        blockData["pushVectorY"] = 1
                                    case  let (_,y) where y>1:
                                        blockData["pushVectorX"] = 0
                                        blockData["pushVectorY"] = -1
                                    case let (x,_) where x > 1:
                                        blockData["pushVectorX"] = -1
                                        blockData["pushVectorY"] = 0
                                    case let (x,_) where x < 0:
                                        blockData["pushVectorX"] = 1
                                        blockData["pushVectorY"] = 0
                                    default:
                                        blockData["pushVectorX"] = 0
                                        blockData["pushVectorY"] = 0
                                    }
                                    break
                                }
                            }
                        }
                        level.blocks.append(Block(blockData: blockData))
                    }
                }
            }
        }
        
        return level
    }
    
    func updateCompletedLevelsByPriority(_ priority:Float){
        if Int(priority) > GameSettings.completedLevels{
            GameSettings.completedLevels = Int(priority)
        }
    }
    
    func levelByPriority(_ priority:Float)->Level?{
        for level in levels{
            if level.priority == priority{
                return level
            }
        }
        return nil
    }
    
    func nextLevelByPriority(_ priority:Float)->Level?{
        for level in levels{
            if level.priority > priority{
                return level
            }
        }
        return nil
    }
    
    func challengeByPriority(_ priority:Float)->Level?{
        for level in challenges{
            if level.priority == priority{
                return level
            }
        }
        return nil
    }
    
    func nextChallengeByPriority(_ priority:Float)->Level?{
        for level in challenges{
            if level.priority > priority{
                return level
            }
        }
        return nil
    }
}
