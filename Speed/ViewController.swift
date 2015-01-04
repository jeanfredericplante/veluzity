//
//  ViewController.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/27/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, LocationUpdateDelegate, WeatherUpdateDelegate {

    @IBOutlet weak var speedDisplay: UILabel!
    @IBOutlet weak var tempDisplay: UILabel!
    @IBOutlet weak var locationDisplay: UILabel!
    @IBOutlet weak var headingDisplay: UILabel!
    
    let userLocation = LocationModel()
    let locationWeather = WeatherModel()
    var defaults: NSUserDefaults!
    var isMph: Bool = true
    var isFahrenheit: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLocation.delegate = self
        locationWeather.myDelegate = self
        defaults = NSUserDefaults.standardUserDefaults()
        isMph = defaults.boolForKey("isMph")
        isFahrenheit = !defaults.boolForKey("isCelsius")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didUpdateLocation() {
        defaults = NSUserDefaults.standardUserDefaults()
        isMph = defaults.boolForKey("isMph")
        isFahrenheit = !defaults.boolForKey("isCelsius")

        //Updates speed in display
        if isMph {
            var localizedSpeed = userLocation.speed * 2.23694
            speedDisplay.text = NSString(format: "%.1f mph", localizedSpeed)
            speedDisplay.attributedText
            
        } else {
            var localizedSpeed = userLocation.speed * 3.6
            speedDisplay.text = NSString(format: "%.1f km/h", localizedSpeed)
        }
        
        // Updates display
        locationDisplay.text = userLocation.streetName
        headingDisplay.text = userLocation.getHeading()
        
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
    

    func updatedTemperature(temperature: Double) {
        println("I got the temperature of \(temperature)")

        if !isFahrenheit {
            tempDisplay.text = NSString(format: "%.1f °C",locationWeather.temperature())
        } else
        {
            tempDisplay.text = NSString(format: "%.1f °F",locationWeather.temperatureFahrenheit())
        }
    }
    
    func getAttributedSpeedUnit()-> NSAttributedString {
        if isMph {
            
        } else {
            
        }
    }
 
}

