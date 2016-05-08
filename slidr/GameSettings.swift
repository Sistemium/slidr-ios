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
    static let pushBlockInterval = 0.5
    static var playableAreaSize = CGSize()
    static var grid = CGSize(width: 6, height: 6) //minium size of grid
    static let blockColor = UIColor.redColor()
    static let speed:CGFloat = 200
    static let moveDirections = [CGVectorMake(0, speed),CGVectorMake(0, -speed),CGVectorMake(speed, 0),CGVectorMake(-speed, 0)]
    static var blockId:UInt32 = 0;
    static var fadeOutDuration = 1.0
}
