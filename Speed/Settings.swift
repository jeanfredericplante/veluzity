//
//  Settings.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 2/27/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation

public class Settings {
    var defaults: NSUserDefaults?
    
    struct Constants {
        static let speedResolution: Int = 5 // in mph or kmh, increment to determine max speed
    }
    

    
    public init () {
        defaults = NSUserDefaults.standardUserDefaults()
        if maxSpeed == 0 { initSettingsAtFirstLaunch() }
    }
    
    public var isMph: Bool {
        get { return defaults?.boolForKey("isMph") ?? true }
        set {
            defaults?.setBool(newValue, forKey: "isMph")
            defaults?.synchronize()
        }
    }
    public var isFahrenheit: Bool {
        get { return (defaults?.boolForKey("isFahrenheit") ?? true) }
        set {
            defaults?.setBool(newValue, forKey: "isFahrenheit")
            defaults?.synchronize()
        }
    }
    
    public func saveDictionary(dictionary: NSDictionary, withKey: String) {
        defaults?.setObject(dictionary, forKey: withKey)
    }
    
    public func restoreDictionaryForKey(key: String) -> NSDictionary? {
        return defaults?.dictionaryForKey(key)
    }
    
    
    
    
    public var maxSpeed: Double {
        get { return defaults?.doubleForKey("maxSpeed")  ?? 0 }
        set {
            var roundedMph: Double
            
            // TODO: could i make that more complex?
            if isMph {
                let maxSpeedMph =  newValue * Params.Conversion.msToMph
                roundedMph = Double((Settings.roundToNearest(increment: Constants.speedResolution, for_value: maxSpeedMph))) / Params.Conversion.msToMph
            } else {
                let maxSpeedKmh = newValue * Params.Conversion.msToKmh
                roundedMph = Double((Settings.roundToNearest(increment: Constants.speedResolution, for_value: maxSpeedKmh))) / Params.Conversion.msToKmh
            }
            
 
            defaults?.setDouble(roundedMph, forKey: "maxSpeed")
            defaults?.synchronize()
        }
    }
      

    
    private func initSettingsAtFirstLaunch(){
        isMph = true
        isFahrenheit = true
        maxSpeed = Params.Initialization.maxSpeedUSA
        defaults?.synchronize()
    }
    
    public class func roundToNearest(increment: Int = 5, for_value value: Double) -> Int {
        return  increment * Int (max(0, round(value / Double(increment))))
    }
    
    
}
