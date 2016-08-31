//
//  Level.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 19/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

enum LevelType:String{
    case Challenge = "Challenge",Puzzle = "Puzzle"
}

struct Level{
    var type:LevelType?
    var name:String?
    var priority:Float?
    var timeout:Double?
    var blocks = [Block]()
    var completionTime:Double?
}
