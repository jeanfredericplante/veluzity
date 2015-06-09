//
//  Settings.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 2/27/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation

@objc public protocol SettingsDelegate {
    optional func didUpdateSettings()
}

public class Settings {
    var defaults: NSUserDefaults?
    public var delegate: SettingsDelegate?
    
    struct Constants {
        static let speedResolution: Int = 5 // in mph or kmh, increment to determine max speed
    }
    
    public init () {
        defaults = NSUserDefaults(suiteName: "group.com.fantasticwhalelabs.Veluzity")
        if maxSpeed == 0 { initSettingsAtFirstLaunch() }
    }
    
    public var isMph: Bool {
        get { return defaults?.boolForKey("isMph") ?? true }
        set {
            defaults?.setBool(newValue, forKey: "isMph")
            defaults?.synchronize()
        }
    }
    
    public var isAlwaysOn: Bool {
        get { return defaults?.boolForKey("preventSleep") ?? false }
        set {
            defaults?.setBool(newValue, forKey: "preventSleep")
            defaults?.synchronize()
        }
    }
    
    
    public var isFahrenheit: Bool {
        get { return (defaults?.boolForKey("isFahrenheit") ?? true) }
        set {
            defaults?.setBool(newValue, forKey: "isFahrenheit")
            self.delegate?.didUpdateSettings?()
            defaults?.synchronize()
        }
    }
    
    
    public func saveDictionary(dictionary: NSDictionary, withKey: String) {
        defaults?.setObject(dictionary, forKey: withKey)
    }
    
    public func restoreDictionaryForKey(key: String) -> NSDictionary? {
        return defaults?.dictionaryForKey(key)
    }
    
    public var maxSpeedWatch: Double {
        get { return maxSpeed }
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
            self.delegate?.didUpdateSettings?()
        }
    }
      

    
    private func initSettingsAtFirstLaunch(){
        // iOS app
        isMph = true; isFahrenheit = true;

        maxSpeed = Params.Initialization.maxSpeedUSA
        defaults?.synchronize()
    }
    
    public class func roundToNearest(increment: Int = 5, for_value value: Double) -> Int {
        return  increment * Int (max(0, round(value / Double(increment))))
    }
    
    
}
