//
//  WeatherComponent.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/28/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import CoreLocation
import Foundation

public enum WeatherIcon: String {
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

public class WeatherModel: NSObject, NSURLConnectionDelegate {
    // create update delegate type
    public typealias WeatherUpdateDelegate = (WeatherModel) -> ()
    
    struct Constants {
        static let minDistanceToUpdateWeather:Double = 500 // distance to travel before we bug openweathermap again in meters
        static let maxTimeBetweenUpdates: NSTimeInterval = 300 // maximum time between updates in seconds
        static let minTimeBetweenUpates: NSTimeInterval = 15
        static let currentWeatherServiceUrl = "http://api.openweathermap.org/data/2.5/weather"
        static let APIKEY = "***REMOVED***"

    }
    

    public var weatherIcon: String?
    public var weatherDescription: String?
    public var lastReadTemperatureCelsius: Double?
    public var lastUpdateTime: NSDate?
    public var coordinates: CLLocationCoordinate2D
    var weatherResponseData: NSMutableData
    public var temperatureUpdated: WeatherUpdateDelegate?
    var weatherApiCallCounts: Int = 0
    public var minDistanceToUpdateWeather = Constants.minDistanceToUpdateWeather
    public var maxTimeBetweenUpdates = Constants.maxTimeBetweenUpdates
  
    
    public override init() {
        weatherResponseData = NSMutableData()
        coordinates = CLLocationCoordinate2D(latitude: 48, longitude: 3)
        lastUpdateTime =  NSDate(timeInterval: -Constants.minTimeBetweenUpates, sinceDate: NSDate())
    }
    
    public func setPosition(newCoordinates: CLLocationCoordinate2D) -> Void {
        self.coordinates = newCoordinates
    }
    
    public func setUpdateTime(time: NSTimeInterval) {
        maxTimeBetweenUpdates = time
    }
    
    public func setUpdateDistance(distance: Double) {
        minDistanceToUpdateWeather = distance
    }
    
    public func shouldUpdateWeather(newCoordinates: CLLocationCoordinate2D) -> Bool {
        
        let lastUpdateLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let newLocation = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        let distance = newLocation.distanceFromLocation(lastUpdateLocation)
        var shouldUpdateBecauseItHasBeenTooLongSinceLastRefresh: Bool
        var hasPassedMinTimeBetweenCalls: Bool
        if (lastUpdateTime == nil) {
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
    
    public func temperature() -> Double? {
        return lastReadTemperatureCelsius
    }
    
    public func temperatureFahrenheit() -> Double? {
        if let tc = lastReadTemperatureCelsius {
            return 9/5 * tc + 32
        } else {
            return nil
        }
    }
    
    public func getWeatherIcon() -> String {
        return weatherIcon ?? "01d"
    }
    
    // Save and restore state
    
    public func saveState() {
        let defaults = Settings()
        var currentTemp = ""
        if let temp = temperature() {
            currentTemp = String(format: "%.0f", temp)
        }
        let state: Dictionary<String,String> = [
            "icon": getWeatherIcon(),
            "temperature": currentTemp,
            "description": getWeatherDescription()]
        
        defaults.saveDictionary(state as NSDictionary, withKey: "WeatherModel.defaults")
    }
    
    public func restoreState() {
        let defaults = Settings()
        let savedState = defaults.restoreDictionaryForKey("WeatherModel.defaults")
        if let state = savedState as? Dictionary<String,String> {
            self.weatherIcon = state["icon"]
            self.weatherDescription = state["description"]
            if let newTemp = state["temperature"] {
                self.lastReadTemperatureCelsius = (newTemp as NSString).doubleValue
            }
        } else {
            // set defaults value for first launch
            self.weatherIcon = "01d"
            self.weatherDescription = "sky is clear"
            self.lastReadTemperatureCelsius = 20
        }
    }
    
    
    public func getWeatherDescription() -> String {
        return self.weatherDescription?.lowercaseString ?? ""
    }
    
        
    public func getWeatherFromAPI()
    {
        var requestURL = Constants.currentWeatherServiceUrl + "?lat=" + coordinates.latitude.description +
        "&lon=" + coordinates.longitude.description +
            "&APPID=" + Constants.APIKEY
        print("url: \(requestURL.debugDescription)")
        let request = NSURLRequest(URL: NSURL(string: requestURL)!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:
            {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                self.weatherApiCallCounts += 1
                print("number of API calls \(self.weatherApiCallCounts) at \(NSDate())")
                if let data = data where error == nil {
                    self.parseAndUpdateModelWithJsonFromAPI(data)
                } else {
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        print("Error sending weather async request")
                    }
                }
            }
        )
        
    }
    
    func parseAndUpdateModelWithJsonFromAPI(json: NSData) {
        do {
            let weatherInfo: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(json, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            let weatherMain: NSDictionary? = weatherInfo?["main"] as? NSDictionary
            let temperatureKelvin: Double? = weatherMain?["temp"] as? Double
            let weather: NSDictionary? = weatherInfo?["weather"] as? NSDictionary
            let weatherDescription: String? = weather?[0]?["description"] as? String
            let weatherIcon: String? = weather?[0]?["icon"] as? String
            self.weatherDescription = weatherDescription
            self.weatherIcon = weatherIcon
            if temperatureKelvin != nil {
                self.lastReadTemperatureCelsius = temperatureKelvin! - 273.15
                self.lastUpdateTime = NSDate() // now
                self.temperatureUpdated!(self)
                
                print("temperature updated to \(lastReadTemperatureCelsius?.description)")
            }
            
        } catch {
            print("invalid json: \(error)")
            
        }
        
    }
    
}
