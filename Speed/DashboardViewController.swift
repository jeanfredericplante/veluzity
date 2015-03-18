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


class DashboardViewController: UIViewController, LocationUpdateDelegate {

    
    @IBOutlet weak var gradientView: ColorGradient!
    @IBOutlet weak var speedDisplay: UILabel!
    @IBOutlet weak var tempDisplay: UILabel!
    @IBOutlet weak var locationDisplay: UILabel!
    @IBOutlet weak var locationSubtextDisplay: UILabel!
    @IBOutlet weak var headingDisplay: UILabel!
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var speedUnit: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var velocityMeter: SpeedMeter!
    @IBOutlet weak var headingView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var speedMeter: SpeedMeter!
    @IBOutlet weak var weatherDescription: UILabel!
    
    
    var userLocation: LocationModel!
    var locationWeather: WeatherModel!
    var defaults: Settings!
    let device : UIDevice = UIDevice.currentDevice()
    let nc = NSNotificationCenter.defaultCenter()

    var delegate: ViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLocation = LocationModel()
        locationWeather = WeatherModel()
        userLocation.delegate = self
        defaults = Settings()

        // initial style for views
        SpeedViewsHelper.setImageAndTextColor(view: headingView,
            color: SpeedViewsHelper.getColorForElement(.Heading))
        SpeedViewsHelper.setImageAndTextColor(view: weatherView,
            color: SpeedViewsHelper.getColorForElement(.Weather))
        SpeedViewsHelper.setImageAndTextColor(view: addressView,
            color: SpeedViewsHelper.getColorForElement(.Location))
        SpeedViewsHelper.setImageAndTextColor(view: speedMeter,
            color: SpeedViewsHelper.getColorForElement(.Speed))
        
        // sets location to undefined until we get one
        notifyLocationUndefined()
        
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
  
        // Updates gradient background
        gradientView.direction = userLocation.getHeadingDegrees()
        gradientView.maxTransitionSpeed = defaults.maxSpeed
        gradientView.speed = userLocation.speed
        
        // Updates displays
        speedDisplay.text = getSpeedWithPreferencesUnit()
        speedUnit.text = getSpeedUnitText()
        if let currentStreet = userLocation.streetName {
            locationDisplay.text = currentStreet
            locationSubtextDisplay.text = SpeedViewsHelper.cityAndStateText(userLocation.cityName,
                state: userLocation.stateName)
        } else {
            notifyLocationUndefined()
        }
        headingDisplay.attributedText = SpeedViewsHelper.headingViewFormattedText(
            userLocation.getHeadingDegrees(),
            cardinality: userLocation.getCardinalDirection(),
            font: headingDisplay.font)
        velocityMeter.maximumSpeed = getMaxSpeed()
        velocityMeter.speed = userLocation.speed

        
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
        if defaults.isFahrenheit {
            temperature = locationWeather.temperatureFahrenheit()
        } else {
            temperature = locationWeather.temperature()
        }
        tempDisplay.attributedText = SpeedViewsHelper.weatherViewFormattedText(temperature,
            description: "", font: tempDisplay.font)
        weatherDescription.text = locationWeather.weatherDescription?.lowercaseString
        weatherIcon.image = locationWeather.getWeatherIconImage()
        SpeedViewsHelper.setImageAndTextColor(view: weatherView,
            color: SpeedViewsHelper.getWeatherColor())
        
    }
     
    func getMaxSpeed() -> Double {
        return  defaults.maxSpeed / Params.SpeedMeter.maxSpeedFractionOfDial
    }
    
    func getLocalizedSpeed() -> Double {
        var localizedSpeed: Double!
        
        if defaults.isMph {
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
        speedText = NSString(format: "%.0f", localizedSpeed)
        return speedText
    }
    
    func getSpeedUnitText() -> String {
        if defaults.isMph {
            return "mp/h"
        } else {
            return "km/h"
        }
    }
    
    private func notifyLocationUndefined() -> Void {
        locationDisplay.text = "Locating..."
        locationSubtextDisplay.text = " "
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

