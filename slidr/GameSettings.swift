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
    static let blockColors = [UIColor.redColor(),UIColor.blueColor()]
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
    static let labelSize: CGFloat = 80
    static var maxNumberOfBlocks = 5
    static let hitSideWidth:CGFloat = 20
    static let touchRegion:CGFloat = 50
}
