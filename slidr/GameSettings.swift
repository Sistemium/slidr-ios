//
//  GameSettings.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 06/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import Foundation
import UIKit

struct GameSettings{
    static var lastKnownOrientation:UIDeviceOrientation = .Portrait
    private static var _playableAreaSize = CGSize()
    static var playableAreaSize:CGSize{
        get{
            return CGSize(width: _playableAreaSize.width * rezolutionNormalizationValue, height: _playableAreaSize.height * rezolutionNormalizationValue)
        }
        set{
            _playableAreaSize = CGSize(width: newValue.width / rezolutionNormalizationValue, height: newValue.height / rezolutionNormalizationValue)
        }
    }
    static var moveDirections:[CGVector]{
        get{
            return [CGVectorMake(0, baseSpeed),CGVectorMake(0, -baseSpeed),CGVectorMake(baseSpeed, 0),CGVectorMake(-baseSpeed, 0)]
        }
    }
    static var toolbarHeight:CGFloat{
        get{
            return 60 * rezolutionNormalizationValue
        }
    }
    static let pushBlockInterval = 0.4
    static var defaultSpeed:CGFloat{
        get{
            return 80000 * rezolutionNormalizationValue
        }
    }
    static var baseSpeed:CGFloat{
        get{
            return NSUserDefaults.standardUserDefaults().valueForKey("baseSpeed") as? CGFloat ?? defaultSpeed
        }
        
        set{
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "baseSpeed")
        }
    }
    static var minBlockSize:UInt32{
        get{
            return UInt32(100.0 * rezolutionNormalizationValue)
        }
    }
    static var maxBlockSize:UInt32{
        get{
            return UInt32(200.0 * rezolutionNormalizationValue)
        }
    }
    static var labelSize: CGFloat{
        get{
            return 85 * rezolutionNormalizationValue
        }
    }
    static var maxNumberOfBlocks = 6
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
    static let freeModeTimer = 10000.0
    static let redBlockReward = 1.5
    static let blueBlockReward = 0.8
    static var lockOrientationInGameEnabled:Bool{
        get{
            if NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys.contains("LockOrientationInGameEnabled"){
                return NSUserDefaults.standardUserDefaults().boolForKey("LockOrientationInGameEnabled")
            }
            else{
                return false
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "LockOrientationInGameEnabled")
        }
    }
    
    static var completedLevels:Int{
        get{
            if NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys.contains("completedLevels"){
                return NSUserDefaults.standardUserDefaults().integerForKey("completedLevels")
            }
            else{
                return 0
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "completedLevels")
        }
    }
    static let blockFadeoutTime = 0.5
    static let boostValue:CGFloat = 1.5
    static let caterpillarDeepth:CGFloat = 0.4
    //Game is optimized for iPad pro, cause it has biggest resolution, if game was launched on device with lower resolution this value helps to downscale expected resolution i onrder to improve perfomance
    static var rezolutionNormalizationValue:CGFloat = 1
    static var rippleRadius:CGFloat{
        get{
            return 30 * rezolutionNormalizationValue
        }
    }
    static var labelOffset:CGFloat{
        get{
            return 3.5 * rezolutionNormalizationValue
        }
    }
    static var caterpillarPartSize:CGFloat{
        get{
            return 200 * rezolutionNormalizationValue
        }
    }
    static let caterpillarSpaceBetweenParts:CGFloat = 0.5
    static var caterpillarSpeed:CGFloat = 0.02
    static var rippleLineWidth:CGFloat{
        get{
            return 15 * rezolutionNormalizationValue
        }
    }
    static var touchRegion:CGFloat{
        return 90 * rezolutionNormalizationValue
    }
    
    static var blurValue:Double = 10.0
}