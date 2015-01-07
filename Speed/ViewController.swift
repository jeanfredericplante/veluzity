//
//  ViewController.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/27/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, LocationUpdateDelegate {

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
        defaults = NSUserDefaults.standardUserDefaults()
        isMph = defaults.boolForKey("isMph")
        isFahrenheit = !defaults.boolForKey("isCelsius")
        
        // completion closure, temperature updated
        locationWeather.temperatureUpdated = { lw in
            println("I got the temperature of \(lw.temperature())")
            self.didUpdateWeather()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didUpdateLocation() {
        defaults = NSUserDefaults.standardUserDefaults()
        isMph = defaults.boolForKey("isMph")
        isFahrenheit = !defaults.boolForKey("isCelsius")

     
        
        // Updates display
        speedDisplay.attributedText = self.getAttributedSpeedText()
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
    
    func didUpdateWeather() {
        if !self.isFahrenheit {
            self.tempDisplay.text = NSString(format: "%.1f °C",locationWeather.temperature())
        } else
        {
            self.tempDisplay.text = NSString(format: "%.1f °F",locationWeather.temperatureFahrenheit())
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
    
    func getAttributedSpeedText()-> NSAttributedString {
        var unitFontSize: CGFloat = round(speedDisplay.font.pointSize / 2)
        var unitFont = speedDisplay.font.fontWithSize(unitFontSize)
        var speedFont = speedDisplay.font
        var localizedSpeed: Double!
        var unitText: String!
        if isMph {
            localizedSpeed = userLocation.speed * 2.23694
            unitText = "mph"
            
        } else {
            localizedSpeed = userLocation.speed * 3.6
            unitText = "kmh"
        }
        var speedText = NSString(format: "%.1f", localizedSpeed)
        var speedAttrText = NSMutableAttributedString(string: speedText, attributes: [NSFontAttributeName: speedFont])
        var unitAttrText = NSMutableAttributedString(string: unitText, attributes: [NSFontAttributeName: unitFont])
        speedAttrText.appendAttributedString(unitAttrText)
        return speedAttrText
    }
    
}

