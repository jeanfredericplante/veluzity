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
    @IBOutlet weak var headingView: UIView!
    @IBOutlet weak var addressView: UIView!
    
    
    
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
        
        // initial style for views
        SpeedViewsHelper.setImageAndTextColor(view: headingView,
            color: SpeedViewsHelper.getHeadingColor())
        SpeedViewsHelper.setImageAndTextColor(view: weatherView,
            color: SpeedViewsHelper.getWeatherColor())
        SpeedViewsHelper.setImageAndTextColor(view: addressView,
            color: SpeedViewsHelper.getLocationColor())
        
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
        headingDisplay.attributedText = SpeedViewsHelper.headingViewFormattedText(
            userLocation.getHeadingDegrees(),
            cardinality: userLocation.getCardinalDirection(),
            font: headingDisplay.font)
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
        var temperature: Double
        if !self.isFahrenheit {
            temperature = locationWeather.temperature()
        } else {
            temperature = locationWeather.temperatureFahrenheit()
        }
        tempDisplay.attributedText = SpeedViewsHelper.weatherViewFormattedText(temperature,
            description: locationWeather.getWeatherDescription(), font: tempDisplay.font)
        weatherIcon.image = locationWeather.getWeatherIconImage()
        SpeedViewsHelper.setImageAndTextColor(view: weatherView,
            color: SpeedViewsHelper.getWeatherColor())
    
    }
    
    // TODO: DRY the temp string function
    func updatedTemperature(temperature: Double) {
        println("I got the temperature of \(temperature)")
        
        if !isFahrenheit {
            self.tempDisplay.text = NSString(format: "%.1f°",locationWeather.temperature())
        } else
        {
            self.tempDisplay.text = NSString(format: "%.1f°",locationWeather.temperatureFahrenheit())
        }
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

