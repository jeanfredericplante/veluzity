//
//  ViewController.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/27/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreLocation

@objc // makes protocol available from Objective C
protocol ViewControllerDelegate {
    optional func togglePreferencePane()
}


class ViewController: UIViewController, LocationUpdateDelegate {

    
    @IBOutlet weak var speedDisplay: UILabel!
    @IBOutlet weak var tempDisplay: UILabel!
    @IBOutlet weak var locationDisplay: UILabel!
    @IBOutlet weak var headingDisplay: UILabel!
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var speedUnit: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var velocityMeter: SpeedMeter!
    
    
    let userLocation = LocationModel()
    let locationWeather = WeatherModel()
    let device : UIDevice = UIDevice.currentDevice()
    let nc = NSNotificationCenter.defaultCenter()
    var defaults: NSUserDefaults!
    var isMph: Bool = true
    var isFahrenheit: Bool = true
    var delegate: ViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLocation.delegate = self
        defaults = NSUserDefaults.standardUserDefaults()
        isMph = defaults.boolForKey("isMph")
        isFahrenheit = !defaults.boolForKey("isCelsius")
        
        // completion closure, temperature updated
        locationWeather.temperatureUpdated = { lw in
            println("I got the temperature of \(lw.temperature())")
            self.didUpdateWeather()
        }
        
        // updates sleep mode
        self.updateSleepMode()
        
        // adds obsever on battery charging state
        nc.addObserver(self, selector: "deviceBatteryStateChanged", name: UIDeviceBatteryStateDidChangeNotification, object: device)
        
        // Set status bar to light
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didUpdateLocation() {
        defaults = NSUserDefaults.standardUserDefaults()
        isMph = defaults.boolForKey("isMph")
        isFahrenheit = !defaults.boolForKey("isCelsius")
        
        
        
        // Updates displays
        speedDisplay.text = getSpeedWithPreferencesUnit()
        speedUnit.text = getSpeedUnitText()
        locationDisplay.text = userLocation.streetName
        headingDisplay.text = userLocation.getHeading()
        velocityMeter.speed = getLocalizedSpeed()
        
        // Updates weather model location
        if (userLocation.coordinates != nil) {
            if locationWeather.shouldUpdateWeather(userLocation.coordinates!) {
                // only update location if the weather will be updated
                locationWeather.setPosition(userLocation.coordinates!)
                // Request update of the weather
                locationWeather.getWeatherFromAPI()
            }
        }
    }
    
    
    func didUpdateWeather() {
        if !self.isFahrenheit {
            self.tempDisplay.text = NSString(format: "%.1f °C",locationWeather.temperature())
        } else
        {
            self.tempDisplay.text = NSString(format: "%.1f °F",locationWeather.temperatureFahrenheit())
        }
        weatherIcon.image = locationWeather.getWeatherIconImage()
    }
    
    
    func updatedTemperature(temperature: Double) {
        println("I got the temperature of \(temperature)")
        
        if !isFahrenheit {
            tempDisplay.text = NSString(format: "%.1f °C",locationWeather.temperature())
        } else
        {
            tempDisplay.text = NSString(format: "%.1f °F",locationWeather.temperatureFahrenheit())
        }
    }
    
    func getAttributedSpeedText()-> NSAttributedString {
        var unitFontSize: CGFloat = round(speedDisplay.font.pointSize / 2)
        var unitFont = speedDisplay.font.fontWithSize(unitFontSize)
        var speedFont = speedDisplay.font
        var unitText = getSpeedUnitText()
        var speedText = getSpeedWithPreferencesUnit()
        var speedAttrText = NSMutableAttributedString(string: speedText, attributes: [NSFontAttributeName: speedFont])
        var unitAttrText = NSMutableAttributedString(string: unitText, attributes: [NSFontAttributeName: unitFont])
        speedAttrText.appendAttributedString(unitAttrText)
        return speedAttrText
    }
    
    
    func getLocalizedSpeed() -> Double {
        var localizedSpeed: Double!
        
        if isMph {
            localizedSpeed = userLocation.speed * 2.23694
        } else {
            localizedSpeed = userLocation.speed * 3.6
        }
        
        if localizedSpeed < 0 { localizedSpeed = 0 }
        return localizedSpeed
    }
    
    func getSpeedWithPreferencesUnit() -> String {
        var speedText: String!
        var localizedSpeed = getLocalizedSpeed()
        speedText = NSString(format: "%.1f", localizedSpeed)
        return speedText
    }
    
    func getSpeedUnitText() -> String {
        if isMph {
            return "mp/h"
        } else {
            return "km/h"
        }
    }
    
    // MARK: Button actions
    
    @IBAction func preferencesTapped(sender: AnyObject) {
        delegate?.togglePreferencePane?()
    }
    
    
    // MARK: Utilities
    // TODO: Move to helper class?
    
    func deviceBatteryStateChanged() {
        updateSleepMode()
    }
    
    func updateSleepMode() {
        var currentBatteryState = device.batteryState;
        UIApplication.sharedApplication().idleTimerDisabled = currentBatteryState == .Charging
    }
    
}

