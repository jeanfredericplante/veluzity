//
//  SpeedToGradientHelpers.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 4/11/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation

public struct SpeedGradientConstants {
    public static let speedAtRedTransition: Double = 28.5
    public static let startToEndDeltaSpeed: Double = 3 //gradient end speed - gradient start speed (current speed) m/s
    
    public static let speedHexLUT :[(Double, Int)] =
    [(0, 0x1e2432),
        (3, 0x0b2051),
        (6, 0x022c8e),
        (9, 0x0955aa),
        (11, 0x1875b6),
        (14, 0x2ba8c7),
        (17, 0x2bb9c2),
        (20, 0x01beaa),
        (23, 0x02bc8a),
        (25, 0x04c254),
        (27, 0x03ce0d),
        (28, 0x75c113),
        (29, 0xa9d71b),
        (30, 0xe4c51c),
        (32, 0xe9ad1c),
        (35, 0xe88c15),
        (37, 0xed6912),
        (38, 0xed2d0d),
        (200, 0xf10638)]
}

public func speedToColorGradient(speed: Double, maxTransitionSpeed: Double) -> (startColor: UIColor, endColor: UIColor)? {
    
    let sc = speedToColor(speed, maxTransitionSpeed: maxTransitionSpeed)
    let ec = speedToColor(speed+SpeedGradientConstants.startToEndDeltaSpeed, maxTransitionSpeed: maxTransitionSpeed )
    return (sc, ec)
}



public func speedToColor(s: Double, maxTransitionSpeed: Double) -> UIColor {
    let normalizedSpeed = normalizeSpeedToMax(s, maxTransitionSpeed: maxTransitionSpeed)
    let firstBigger = SpeedGradientConstants.speedHexLUT.filter{ (lutspeed,_) in lutspeed >= normalizedSpeed }.first
    let lastSmaller = SpeedGradientConstants.speedHexLUT.filter{ (lutspeed,_) in lutspeed <= normalizedSpeed }.last
    let location = (firstBigger, lastSmaller)
    
    switch location {
    case (nil,.Some(let (_,h2))):
        return hexToUIColor(h2)
    case (.Some(let (_,h1)), nil):
        return hexToUIColor(h1)
    case (.Some(let (s1,h1)), .Some(let (s2,h2))):
        let rgb1 = hexToRGB(h1)
        let rgb2 = hexToRGB(h2)
        let ri = interp1(x0: s1, x1: s2, y0: rgb1.r, y1: rgb2.r, x: normalizedSpeed)
        let gi = interp1(x0: s1, x1: s2, y0: rgb1.g, y1: rgb2.g, x: normalizedSpeed)
        let bi = interp1(x0: s1, x1: s2, y0: rgb1.b, y1: rgb2.b, x: normalizedSpeed)
        return UIColor(red: ri, green: gi, blue: bi, alpha: 1)
    default:
        return UIColor.blackColor()
        
    }
}

public func normalizeSpeedToMax(speed: Double, maxTransitionSpeed: Double) -> Double {
    if maxTransitionSpeed == 0 {
        return 0
    } else {
        return max(0.0, speed*SpeedGradientConstants.speedAtRedTransition/maxTransitionSpeed)
    }
}

public func interp1(x0 x0: Double, x1: Double, y0: CGFloat, y1: CGFloat, x: Double) -> CGFloat {
    let slider = CGFloat(Double(x-x0) / Double(x1-x0)) // need to split into as got weird archive error
    let boundedSlider = min(1.0, max(0.0, slider))
    return y0 + (y1 - y0)*boundedSlider
}


public func hexToUIColor(hexValue: Int) -> UIColor {
    let (red,green,blue) = hexToRGB(hexValue)
    return UIColor(red: red, green: green, blue: blue, alpha: 1)
}

public func hexToRGB(hexValue: Int) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
    let red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
    let green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
    let blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
    return (red, green, blue)
}

