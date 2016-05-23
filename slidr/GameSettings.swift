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
    static let fadeOutDuration = 1.0
    static let blockColors = [UIColor.redColor()]
    static let toolbarHeight:CGFloat = 30
    static let pushBlockInterval = 0.4
    static var baseSpeed:CGFloat = 11000
    static let minBlockSize:UInt32 = 50
    static let maxBlockSize:UInt32 = 100
    static let labelSize: CGFloat = 35
    static var maxNumberOfBlocks = 5
}
