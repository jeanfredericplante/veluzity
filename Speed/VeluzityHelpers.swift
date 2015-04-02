//
//  VeluzityHelpers.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 4/1/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation

public func localizeSpeed(speed: Double, #isMph: Bool) -> Double {
    var localizedSpeed: Double
    
    if isMph {
        localizedSpeed = speed * Params.Conversion.msToMph
    } else {
        localizedSpeed = speed * Params.Conversion.msToKmh
    }
    
    if localizedSpeed < 0 { localizedSpeed = 0 }
    return localizedSpeed
}
