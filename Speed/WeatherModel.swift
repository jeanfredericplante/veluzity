//
//  WeatherComponent.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/28/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

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
    
    struct Constants {
        static let minDistanceToUpdateWeather:Double = 500 // distance to travel before we bug openweathermap again in meters
        static let maxTimeBetweenUpdates: NSTimeInterval = 300 // maximum time between updates in seconds
        static let minTimeBetweenUpates: NSTimeInterval = 15
        static let currentWeatherServiceUrl = "http://api.openweathermap.org/data/2.5/weather"

    }
    

    var weatherIcon: String?
    var weatherDescription: String?
    var lastReadTemperatureCelsius: Double?
    var lastUpdateTime: NSDate?
    var coordinates: CLLocationCoordinate2D
    var weatherResponseData: NSMutableData
    var temperatureUpdated: WeatherUpdateDelegate?
    var weatherApiCallCounts: Int = 0
    var minDistanceToUpdateWeather = Constants.minDistanceToUpdateWeather
    var maxTimeBetweenUpdates = Constants.maxTimeBetweenUpdates
  
    
    override init() {
        weatherResponseData = NSMutableData()
        coordinates = CLLocationCoordinate2D(latitude: 48, longitude: 3)
        lastUpdateTime =  NSDate(timeInterval: -Constants.minTimeBetweenUpates, sinceDate: NSDate())
    }
    
    func setPosition(newCoordinates: CLLocationCoordinate2D) -> Void {
        self.coordinates = newCoordinates
    }
    
    func setUpdateTime(time: NSTimeInterval) {
        maxTimeBetweenUpdates = time
    }
    
    func setUpdateDistance(distance: Double) {
        minDistanceToUpdateWeather = distance
    }
    
    func shouldUpdateWeather(newCoordinates: CLLocationCoordinate2D) -> Bool {
        
        var lastUpdateLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        var newLocation = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        var distance = newLocation.distanceFromLocation(lastUpdateLocation)
        var shouldUpdateBecauseItHasBeenTooLongSinceLastRefresh: Bool
        var hasPassedMinTimeBetweenCalls: Bool
        if (lastUpdateTime? == nil) {
            shouldUpdateBecauseItHasBeenTooLongSinceLastRefresh = true
            hasPassedMinTimeBetweenCalls = true
        } else {
            shouldUpdateBecauseItHasBeenTooLongSinceLastRefresh =
                lastUpdateTime!.timeIntervalSinceNow < -maxTimeBetweenUpdates // timeSinceInterval will be negative
            hasPassedMinTimeBetweenCalls = lastUpdateTime!.timeIntervalSinceNow < -Constants.minTimeBetweenUpates
        }
        if (distance > minDistanceToUpdateWeather && hasPassedMinTimeBetweenCalls) || shouldUpdateBecauseItHasBeenTooLongSinceLastRefresh {
            return true
        } else {
            return false
        }
    }
    
    func temperature() -> Double? {
        return lastReadTemperatureCelsius?
    }
    
    func temperatureFahrenheit() -> Double? {
        if let tc = lastReadTemperatureCelsius {
            return 9/5 * tc + 32
        } else {
            return nil
        }
    }
    
    func getWeatherIcon() -> String {
        return weatherIcon? ?? "01d"
    }
    
    // Save and restore state
    
    func saveState() {
        let defaults = Settings()
        var currentTemp = ""
        if let temp = temperature() {
            currentTemp = String(format: "%.0f", temp)
        }
        var state: Dictionary<String,String> = [
            "icon": getWeatherIcon(),
            "temperature": currentTemp,
            "description": getWeatherDescription()]
        
        defaults.saveDictionary(state as NSDictionary, withKey: "WeatherModel.defaults")
    }
    
    func restoreState() {
        let defaults = Settings()
        var savedState = defaults.restoreDictionaryForKey("WeatherModel.defaults")
        if let state = savedState as? Dictionary<String,String> {
            self.weatherIcon = state["icon"]
            self.weatherDescription = state["description"]
            if let newTemp = state["temperature"] {
                self.lastReadTemperatureCelsius = (newTemp as NSString).doubleValue
            }
        }
    }
    
    // TODO: Shouldn't be any ui image here
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
    
    
    func getWeatherDescription() -> String {
        return self.weatherDescription?.lowercaseString ?? ""
    }
    
        
    func getWeatherFromAPI()
    {
        var requestURL = Constants.currentWeatherServiceUrl + "?lat=" + coordinates.latitude.description +
        "&lon=" + coordinates.longitude.description
        println("url: \(requestURL.debugDescription)")
        let request = NSURLRequest(URL: NSURL(string: requestURL)!)
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:
            {
                (response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                self.weatherApiCallCounts++
                println("number of API calls \(self.weatherApiCallCounts) at \(NSDate())")
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
                
                println("temperature updated to \(lastReadTemperatureCelsius?.description)")
            }
            
        } else {
            println("invalid json: \(myError?.localizedDescription)")
        }
    }
    
}
