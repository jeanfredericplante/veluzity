//
//  WeatherComponent.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/28/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreLocation


class WeatherModel: NSObject, NSURLConnectionDelegate {
    // create update delegate type
    typealias WeatherUpdateDelegate = (WeatherModel) -> ()
    
    let currentWeatherServiceUrl = "http://api.openweathermap.org/data/2.5/weather"
    
    var minDistanceToUpdateWeather:Double = 500 // distance to travel before we bug openweathermap again in meters
    var maxTimeBetweenUpdates: NSTimeInterval = 300 // maximum time between updates in seconds
    var lastReadTemperatureCelsius: Double
    var lastUpdateTime: NSDate?
    var coordinates: CLLocationCoordinate2D
    var weatherResponseData: NSMutableData
    var temperatureUpdated: WeatherUpdateDelegate?
    
    
    override init() {
        weatherResponseData = NSMutableData()
        lastReadTemperatureCelsius = 20
        coordinates = CLLocationCoordinate2D(latitude: 48, longitude: 3)
    }
    
    func setPosition(newCoordinates: CLLocationCoordinate2D) -> Void {
        self.coordinates = newCoordinates
    }
    
    func setUpdateTime(time: NSTimeInterval) {
        self.maxTimeBetweenUpdates = time
    }
    
    func setUpdateDistance(distance: Double) {
        self.minDistanceToUpdateWeather = distance
    }
    
    func shouldUpdateWeather(newCoordinates: CLLocationCoordinate2D) -> Bool {
        
        var lastUpdateLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        var newLocation = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        var distance = newLocation.distanceFromLocation(lastUpdateLocation)
        var shouldUpdateBecauseItHasBeenTooLongSinceLastRefresh: Bool
        if (lastUpdateTime? == nil) {
            shouldUpdateBecauseItHasBeenTooLongSinceLastRefresh = true
        } else {
            shouldUpdateBecauseItHasBeenTooLongSinceLastRefresh =
                lastUpdateTime!.timeIntervalSinceNow < -maxTimeBetweenUpdates // timeSinceInterval will be negative
        }
        if (distance > minDistanceToUpdateWeather) || shouldUpdateBecauseItHasBeenTooLongSinceLastRefresh {
            return true
        } else {
            return false
        }
    }
    
    func temperature() -> Double {
        return lastReadTemperatureCelsius
    }
    
    func temperatureFahrenheit() -> Double {
        return lastReadTemperatureCelsius*9/5+32
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
        var myError: NSError?
        var weatherInfo: NSDictionary? = NSJSONSerialization.JSONObjectWithData(json, options: NSJSONReadingOptions.MutableContainers, error: &myError) as NSDictionary?
        if (myError == nil) {
            var weatherMain: NSDictionary? = weatherInfo?["main"] as NSDictionary?
            var temperatureKelvin: Double? = weatherMain?["temp"] as Double?
            if temperatureKelvin != nil {
                self.lastReadTemperatureCelsius = temperatureKelvin! - 273.15
                self.lastUpdateTime = NSDate() // now
                self.temperatureUpdated!(self)
                
                println("temperature updated to \(lastReadTemperatureCelsius.description)")
            }
        } else {
            println("invalid json: \(myError?.localizedDescription)")
        }
    }
    
}
