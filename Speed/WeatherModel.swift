//
//  WeatherComponent.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/28/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreLocation

enum WeatherIcon: String {
    case ClearSky = "01d"
    case FewClouds = "02d"
    case ScatteredClouds = "03d"
    case BrokenClouds = "04d"
    case ShowerRain = "09d"
    case Rain = "10d"
    case ThunderStorm = "11d"
    case Snow = "13d"
    case Mist = "50d"
    
    case ClearSkyNight = "01n"
    case FewCloudsNight = "02n"
    case ScatteredCloudsNight = "03n"
    case BrokenCloudsNight = "04n"
    case ShowerRainNight = "09n"
    case RainNight = "10n"
    case ThunderStormNight = "11n"
    case SnowNight = "13n"
    case MistNight = "50n"
    
    func simpleDescription() -> String {
        switch self {
        default:
            return String(self.rawValue)
        }
    }
    
    func fileName() -> String {
        switch self {
        default:
            return String(self.rawValue)+".png"
        }
    }
}

class WeatherModel: NSObject, NSURLConnectionDelegate {
    // create update delegate type
    typealias WeatherUpdateDelegate = (WeatherModel) -> ()
    
    let currentWeatherServiceUrl = "http://api.openweathermap.org/data/2.5/weather"
    
    var weatherIcon: String! = nil
    var weatherDescription: String! = nil
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
    
    func getWeatherIcon() -> String {
        return self.weatherIcon
    }
    
    // TODO: Shouldn't be any ui image here
    func getWeatherIconImage() -> UIImage {
        let wi = WeatherIcon(rawValue: self.weatherIcon)
        if wi == nil {
            return UIImage()
        } else {
            var imageName: String = wi!.rawValue + "White.png"
            return UIImage(named: imageName)!
        }
    }
    
    
    func getWeatherDescription() -> String {
        return self.weatherDescription.lowercaseString
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
            var weatherDescr: NSDictionary? = weatherInfo?["weather"]?[0] as NSDictionary?
            self.weatherDescription = weatherDescr?["description"] as String?
            self.weatherIcon = weatherDescr?["icon"] as String?
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
