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
    static let moveDirections = [CGVectorMake(0, baseSpeed),CGVectorMake(0, -baseSpeed),CGVectorMake(baseSpeed, 0),CGVectorMake(-baseSpeed, 0)]
    static var blockId:UInt32 = 0
    static let fadeOutDuration = 1.0
    static let blockColor = UIColor.redColor()
    
    static let pushBlockInterval = 0.0
    static let baseSpeed:CGFloat = 9000
    static let minBlockSize:UInt32 = 35
    static let maxBlockSize:UInt32 = 70
    static let scoreNodeSize: CGFloat = 25
    static var maxNumberOfBlocks = 3
}
