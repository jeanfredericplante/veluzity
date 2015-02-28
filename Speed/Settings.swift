//
//  Settings.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 2/27/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation

class Settings {
    var defaults: NSUserDefaults?
    
    var isMph: Bool {
        get { return defaults?.boolForKey("isMph") ?? true }
        set { defaults?.setBool(newValue, forKey: "isMph") }
    }
    var isFahrenheit: Bool {
        get { return (defaults?.boolForKey("isFahrenheit") ?? true) }
        set { defaults?.setBool(newValue, forKey: "isFahrenheit") }
    }
    var maxSpeed: Double {
        get { return defaults?.doubleForKey("maxSpeed")  ?? 0 }
        set { defaults?.setDouble(newValue, forKey: "maxSpeed") }
    }

    
    init () {
        defaults = NSUserDefaults.standardUserDefaults()
        if maxSpeed == 0 { setMaxSpeedPreference() }
    }
    
    private func setMaxSpeedPreference(){
        if isMph {
            maxSpeed = Params.Initialization.maxSpeedUSA
        } else {
            maxSpeed = Params.Initialization.maxSpeedEurope
        }
        defaults?.synchronize()
    }
    
}
