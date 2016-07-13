//
//  GameSettings.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 06/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import Foundation
import UIKit

class GameSettings{
    static var playableAreaSize = CGSize()
    static var moveDirections:[CGVector]{
        get{
            return [CGVectorMake(0, baseSpeed),CGVectorMake(0, -baseSpeed),CGVectorMake(baseSpeed, 0),CGVectorMake(-baseSpeed, 0)]
        }
    }
    static let fadeOutDuration = 0.75
    static let toolbarHeight:CGFloat = 60
    static let pushBlockInterval = 0.4
    static let defaultSpeed:CGFloat = 45000
    static var baseSpeed:CGFloat{
        get{
            return NSUserDefaults.standardUserDefaults().valueForKey("baseSpeed") as? CGFloat ?? defaultSpeed
        }
        
        set{
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "baseSpeed")
        }
    }
    static let minBlockSize:UInt32 = 100
    static let maxBlockSize:UInt32 = 200
    static let labelSize: CGFloat = 100
    static var maxNumberOfBlocks = 6
    static let hitSideWidth:CGFloat = 20
    static let touchRegion:CGFloat = 90
    static let timeUntilWarning = 3.0
    static var shakeToResetEnabled:Bool{
        get{
            if NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys.contains("ShakeToResetEnabled"){
                return NSUserDefaults.standardUserDefaults().boolForKey("ShakeToResetEnabled")
            }
            else{
                return true
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "ShakeToResetEnabled")
        }
    }
    static let freeModeTimer = 10.0
    static let redBlockReward = 1.5
    static let blueBlockReward = 1.5
}