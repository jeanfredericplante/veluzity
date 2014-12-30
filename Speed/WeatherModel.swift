//
//  WeatherComponent.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/28/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreLocation

protocol WeatherUpdateDelegate {
    func updatedTemperature(temperature: Double)
}

class WeatherModel: NSObject, NSURLConnectionDelegate {
    let currentWeatherServiceUrl = "http://api.openweathermap.org/data/2.5/weather"
    let minDistanceToUpdateWeather:Double = 150 // distance to travel before we bug openweathermap again
    var lastReadTemperatureCelsius: Double
    var coordinates: CLLocationCoordinate2D
//    var currentLatitude: Double
//    var currentLongitude: Double
    var weatherResponseData: NSMutableData
    var myDelegate: WeatherUpdateDelegate?
    
    override init() {
        weatherResponseData = NSMutableData()
        lastReadTemperatureCelsius = 20
        coordinates = CLLocationCoordinate2D(latitude: 48, longitude: 3)
    }
    
    func setPosition(newCoordinates: CLLocationCoordinate2D) -> Void {
        self.coordinates = newCoordinates
    }
    
    func shouldUpdateWeather(newCoordinates: CLLocationCoordinate2D) -> Bool {
        
        var lastUpdateLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        var newLocation = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        var distance = newLocation.distanceFromLocation(lastUpdateLocation)
        if distance > minDistanceToUpdateWeather {
            return true
        } else {
            return false
        }
        
    }
    
    func temperature() -> Double {
        return lastReadTemperatureCelsius
    }
    
    
        
    func getWeatherFromAPI()
    {
        var requestURL = currentWeatherServiceUrl + "?lat=" + coordinates.latitude.description +
        "&lon=" + coordinates.longitude.description
        println("url: \(requestURL.debugDescription)")
        let request = NSURLRequest(URL: NSURL(string: requestURL)!)
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:
            {
                (response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    self.parseAndUpdateModelWithJsonFromAPI(data)
                } else {
                    println("Error: \(error.localizedDescription)")
                }
            }
        )
        
    }
    
    func parseAndUpdateModelWithJsonFromAPI(json: NSData) {
        var error: NSError?
        var weatherInfo: NSDictionary = NSJSONSerialization.JSONObjectWithData(json, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        if (error == nil) {
            var weatherMain: NSDictionary? = weatherInfo["main"] as NSDictionary?
            var temperatureKelvin: Double? = weatherMain?["temp"] as Double?
            if temperatureKelvin != nil {
                self.lastReadTemperatureCelsius = temperatureKelvin! - 273.15
                self.myDelegate?.updatedTemperature(self.temperature())

                println("temperature updated to \(lastReadTemperatureCelsius.description)")
            }
        } else {
            println("invalid json: \(error?.localizedDescription)")
        }
    }
    
}
