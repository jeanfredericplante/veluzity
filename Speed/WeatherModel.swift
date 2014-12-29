//
//  WeatherComponent.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/28/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit

protocol WeatherUpdateDelegate {
    func updatedTemperature(temperature: Float)
}

class WeatherModel: NSObject, NSURLConnectionDelegate {
    let currentWeatherServiceUrl = "http//api.openweathermap.org/data/2.5/weather"
    var lastReadTemperatureCelsius: Float
    var currentLatitude: Float
    var currentLongitude: Float
    var weatherResponseData: NSMutableData
    
    override init() {
        weatherResponseData = NSMutableData()
        lastReadTemperatureCelsius = 20
        currentLatitude = 48
        currentLongitude = 3
    }
    
    func setPosition(latitude: Float, longitude: Float) -> Void {
        currentLongitude = longitude
        currentLatitude = latitude
    }
    
    func temperature() -> Float {
        return lastReadTemperatureCelsius
    }
    
    func getTemperatureFromAPI()
    {
        var requestURL = currentWeatherServiceUrl + "?lat=" + currentLatitude.description +
        "&lon=" + currentLongitude.description
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
            var temperatureKelvin: Float? = weatherMain?["temp"] as Float?
            if temperatureKelvin != nil {
                self.lastReadTemperatureCelsius = temperatureKelvin!
                println("temperature update to \(lastReadTemperatureCelsius.description)")
            }
        } else {
            println("invalid json: \(error?.localizedDescription)")
        }
    }
    
}
