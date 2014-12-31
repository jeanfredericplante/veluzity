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
    
    let userLocation = LocationModel()
    let locationWeather = WeatherModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLocation.delegate = self
        locationWeather.myDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didUpdateLocation() {
        var speedInKmh = userLocation.speed * 3.6
        
        // Updates display
        speedDisplay.text = NSString(format: "%.1f km/h", speedInKmh)
        
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
        tempDisplay.text = NSString(format: "%.1f °C",locationWeather.temperature())
    }
 
}

