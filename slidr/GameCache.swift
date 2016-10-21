//
//  GameCache.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 10/10/2016.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import SpriteKit

class GameCashe{
    static let sharedInstance = GameCashe()
    fileprivate init() {}
    var texturesY = Dict2D<CGSize,Int,SKTexture>()
    var texturesX = Dict2D<CGSize,Int,SKTexture>()
}
