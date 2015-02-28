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
    
    init () {
        defaults = NSUserDefaults.standardUserDefaults()
        let test = defaults?.boolForKey("isMph")
        defaults?.synchronize()
        if maxSpeed == 0 { setMaxSpeedPreference() }
    }
    
    var isMph: Bool {
        get { return defaults?.boolForKey("isMph") ?? true }
        set {
            defaults?.setBool(newValue, forKey: "isMph")
            defaults?.synchronize()
        }
    }
    var isFahrenheit: Bool {
        get { return (defaults?.boolForKey("isFahrenheit") ?? true) }
        set {
            defaults?.setBool(newValue, forKey: "isFahrenheit")
            defaults?.synchronize()
        }
    }
    var maxSpeed: Double {
        get { return defaults?.doubleForKey("maxSpeed")  ?? 0 }
        set {
            defaults?.setDouble(newValue, forKey: "maxSpeed")
            defaults?.synchronize()
        }
    }

    

    
    private func setMaxSpeedPreference(){
        if isMph {
            maxSpeed = Params.Initialization.maxSpeedUSA
        } else {
            maxSpeed = Params.Initialization.maxSpeedEurope
        }
    }
    
}
