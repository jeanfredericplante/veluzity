//
//  Setup.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 2/26/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation

struct Params {
    
    // Defaults
    var defaults: NSUserDefaults
        { return NSUserDefaults.standardUserDefaults() }
    var isMph: Bool {
        get { return defaults.boolForKey("isMph") }
        set { defaults.setBool(newValue, forKey: "isMph") }
    }
    
    struct Initialization {
        // in m/s
        static let maxSpeedUSA = 29.0
        static let maxSpeedEurope = 36.1
    }

    
}
