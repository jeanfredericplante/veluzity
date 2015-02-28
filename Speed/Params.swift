//
//  Setup.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 2/26/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation

struct Params {
    
    struct Initialization {
        // in m/s
        static let maxSpeedUSA = 29.0
        static let maxSpeedEurope = 36.1
    }
    
    struct SpeedMeter {
        static let maxSpeedFractionOfDial = 0.6
    }
    
    struct PreferencePane {
        static let minMaxSpeedSlider = 8
        static let maxMaxSpeedSlider = 50
    }
    
    struct Conversion {
        static let msToKmh = 3.6
        static let msToMph = 2.236
    }

    
}
