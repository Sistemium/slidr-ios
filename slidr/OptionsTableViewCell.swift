//
//  OptionsTableViewCell.swift
//  slidr
//
//  Created by Edgar Jan Vuicik on 24/05/16.
//  Copyright © 2016 Edgar Jan Vuicik. All rights reserved.
//

import UIKit

class OptionsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var slider: UISlider!{
        didSet{
            slider.minimumValue = 1000
            slider.maximumValue = 20000
            slider.setValue(Float(GameSettings.baseSpeed), animated: false)
        }
    }
    
    @IBOutlet weak var speedLabel: UILabel!{
        didSet{
        speedLabel.text = GameSettings.baseSpeed.fixedFractionDigits(0)
        }
    }
    
    @IBAction func changeSpeed(sender: UISlider) {
        
        GameSettings.baseSpeed = CGFloat(sender.value)
        speedLabel.text = GameSettings.baseSpeed.fixedFractionDigits(0)
        
    }
    

}
