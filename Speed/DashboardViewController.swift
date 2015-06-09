//
//  ViewController.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/27/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreLocation
import VeluzityKit

@objc // makes protocol available from Objective C
protocol ViewControllerDelegate {
    optional func toggleSlideOut()
}

extension WeatherModel {
    func getWeatherIconImage() -> UIImage? {
        let wi = WeatherIcon(rawValue: getWeatherIcon())
        if wi == nil {
            return nil
        } else {
            var imageName: String = wi!.rawValue + "White.png"
            if let currentImage = UIImage(named: imageName) {
                return currentImage
            } else {
                return nil
            }
        }
    }
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
        
        
        // Add enter background observer to save state, stop location updates
        nc.addObserver(self, selector: Selector("applicationDidEnterBackground"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        // Add application active observer to restore state, start location updates
        nc.addObserver(self, selector: Selector("applicationWillBecomeActive"), name: UIApplicationWillEnterForegroundNotification, object: nil)

        // Set status bar to light
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func didUpdateLocation() {
        
        println("updating location")
  
        // Updates gradient background
        gradientView.direction = userLocation.getHeadingDegrees()
        gradientView.maxTransitionSpeed = defaults.maxSpeed
        gradientView.speed = userLocation.speed
        
        // Updates displays
        updatesSpeedometerDialWhenItCan()
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
        Flurry.logEvent("openweather_request")
        var temperature: Double?
        if defaults.isFahrenheit {
            temperature = locationWeather.temperatureFahrenheit()
        } else {
            temperature = locationWeather.temperature()
        }
        tempDisplay.text = SpeedViewsHelper.formattedTemperature(temperature)
        weatherDescription.text = locationWeather.weatherDescription?.lowercaseString
        weatherIcon.image = locationWeather.getWeatherIconImage()
        SpeedViewsHelper.setImageAndTextColor(view: weatherView,
            color: SpeedViewsHelper.getWeatherColor())
        
    }
     
    func getMaxSpeed() -> Double {
        return  defaults.maxSpeed / Params.SpeedMeter.maxSpeedFractionOfDial
    }
    
    func getLocalizedSpeed() -> Double? {
        return localizeSpeed(userLocation.speed, isMph: defaults.isMph)
    }
    
    func updatesSpeedometerDialWhenItCan() {
        if let currentSpeed = getSpeedWithPreferencesUnit() {
            speedDisplay.alpha = 1
            speedUnit.alpha = 1
            speedDisplay.text = currentSpeed
        } else {
            speedDisplay.alpha = 0.1
            speedUnit.alpha = 0.1
        }
        speedUnit.text = getSpeedUnitText()

    }
    
    func getSpeedWithPreferencesUnit() -> String? {
        var speedText: String?
        if let localizedSpeed = getLocalizedSpeed() {
            speedText = String(format: "%.0f", localizedSpeed) }
        else {
            speedText = nil
        }

        return speedText
    }
    
    func getSpeedUnitText() -> String {
        if defaults.isMph {
            return "mph"
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
        delegate?.toggleSlideOut?()
    }
    
    
    // MARK: Class extension
    

    
    // MARK: Utilities
    // TODO: Move to helper class?
    
    func deviceBatteryStateChanged() {
        updateSleepMode()
    }
    
    func updateSleepMode() {
        println("always on mode is: \(defaults.isAlwaysOn)")
        switch device.batteryState {
        case .Charging, .Full:
            UIApplication.sharedApplication().idleTimerDisabled = true
        default:
            if defaults.isAlwaysOn {
                UIApplication.sharedApplication().idleTimerDisabled = true
            } else {
                UIApplication.sharedApplication().idleTimerDisabled = false
            }
        }
    }
    
    func saveState() {
        locationWeather.saveState()
    }
    
    func applicationDidEnterBackground() {
        saveState()
        userLocation.stopUpdatingLocation()
    }
    
    func applicationWillBecomeActive() {
        locationWeather.restoreState()
        userLocation.startUpdatingLocation()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        userLocation.stopUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        userLocation.startUpdatingLocation()
        let locationStatus = userLocation.authorizationStatus()
        presentAlertIfLocationAuthorizationNotAuthorized(locationStatus)

        // Set status bar to light
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.didUpdateWeather()
    }
    
    
    // MARK: Location authorization services alerting
    
    func didChangeLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            self.userLocation.startUpdatingLocation()
        default:
            presentAlertIfLocationAuthorizationNotAuthorized(status)
        }
    }
    
    func presentAlertIfLocationAuthorizationNotAuthorized(status: CLAuthorizationStatus) {
        switch status {
        case .Denied:
            self.userLocation.stopUpdatingLocation()
            askUserToTurnOnLocationServices()
        case .Restricted:
            self.userLocation.stopUpdatingLocation()
            alertUserLocationServicesAreRestricted()
        default:
            break
        }
    }
    

    
    func askUserToTurnOnLocationServices() {
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "Veluzity needs location access in order to get the speed, location and heading. Please open this app's  settings and enable location access.",
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(openAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func alertUserLocationServicesAreRestricted() {
        let alertController = UIAlertController(
            title: "Location Access Restricted",
            message: "Veluzity needs location access in order to get the speed, but your device currently restricts the access to location services.",
            preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    
}

