//
//  Level.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 19/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

struct Level{
    var name:String?
    var priority:Float?
    var timeout:Double?
    var blocks = [Block]()
    var completionTime:Double?
}
