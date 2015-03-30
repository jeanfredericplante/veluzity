//
//  Setup.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 2/26/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation

public struct Params {
    
    public struct Initialization {
        // in m/s
        public static let maxSpeedUSA = 29.0
        public static let maxSpeedEurope = 36.1
    }
    
    public struct SpeedMeter {
        public  static let maxSpeedFractionOfDial = 0.6
    }
    
    public struct PreferencePane {
        public static let minMaxSpeedSlider = 8
        public static let maxMaxSpeedSlider = 50
    }
    
    public struct Conversion {
        public static let msToKmh = 3.6
        public static let msToMph = 2.236
    }
    
   

    
}
