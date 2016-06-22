//
//  ShakeSwitchTableViewCell.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 22/06/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import UIKit

class ShakeSwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shakeSwitcher: UISwitch!{
        didSet{
            shakeSwitcher.on = GameSettings.shakeToResetEnabled
        }
    }
    
    @IBAction func switchShakeToReset(sender: AnyObject) {
        GameSettings.shakeToResetEnabled = shakeSwitcher.on
    }
}
