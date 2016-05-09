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
    static let moveDirections = [CGVectorMake(0, speed),CGVectorMake(0, -speed),CGVectorMake(speed, 0),CGVectorMake(-speed, 0)]
    static var blockId:UInt32 = 0
    static let fadeOutDuration = 1.0
    static let blockColor = UIColor.redColor()
    
    static let pushBlockInterval = 0.5
    static let speed:CGFloat = 100
    static let minBlockSize:UInt32 = 35
    static let maxBlockSize:UInt32 = 70
}
