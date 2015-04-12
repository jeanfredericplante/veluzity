//
//  LocationModel.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/28/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

//import UIKit
import CoreLocation
import AddressBook

@objc
public protocol LocationUpdateDelegate {
    func didUpdateLocation()
    func didChangeLocationAuthorizationStatus(status: CLAuthorizationStatus)
}

public class LocationModel: NSObject, CLLocationManagerDelegate {
    private(set) public var speed: Double = 0.0 // speed in m/s
    private(set) public var altitude: Double = 0.0 // altitude in meters
    public var coordinates: CLLocationCoordinate2D?
    public var course: CLLocationDirection? // North/East/West/South
    let locationManager = CLLocationManager()
    let locationGeoCoder = CLGeocoder()
    public var delegate: LocationUpdateDelegate?
    public var streetName: String?
    public var cityName: String?
    public var stateName: String?
    
    public override init() {
        super.init()
        setupLocationManager()

    }
    
    
    func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.activityType = CLActivityType.AutomotiveNavigation
        let currentStatus = CLLocationManager.authorizationStatus()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    public func speedInKmh() -> Double {
        return speed * 3.6
    }
    
    
    
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.speed = manager.location.speed
        self.coordinates = manager.location.coordinate
        self.course = manager.location.course
        self.getStreetName(manager.location)
        self.delegate?.didUpdateLocation()
        
    }
    
    public func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    public func authorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            self.delegate?.didChangeLocationAuthorizationStatus(status)
        case .NotDetermined:
            manager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            self.delegate?.didChangeLocationAuthorizationStatus(status)
        default:
            break
        }
    }
    
 
    public func getStreetName(location: CLLocation) {
        locationGeoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if error != nil {
                println("reverse location failed")
            } else {
                if placemarks.count > 0 {
                    if let placemark: CLPlacemark = placemarks[0] as? CLPlacemark {
                        self.streetName = placemark.thoroughfare
                        self.cityName = placemark.locality
                        self.stateName = placemark.administrativeArea
                        
                        self.delegate?.didUpdateLocation()
                    }
                }
            }
        }
    }
    
    
    public func getHeading() -> String {
        if course != nil && course >= 0  {
            var cardHeading = getCardinalDirectionFromHeading(self.course!)
            return String(format: "%.0f° %@", self.course!, cardHeading) }
        else {
            return ""
        }
    }
    
  
    public func getCardinalDirection() -> String {
        if course != nil && course >= 0  {
            return getCardinalDirectionFromHeading(self.course!)}
        else {
            return ""
        }
    }
    
    public func getHeadingDegrees() -> Double {
        return self.course!
    }
    
    public func getCardinalDirectionFromHeading(course: Double) -> String {
        var modCourse = Int(round(course%360))
        switch modCourse   {
        case 0...22:
            return "N"
        case 23...67:
            return "NE"
        case 68...112:
            return "E"
        case 113...157:
            return "SE"
        case 158...202:
            return "S"
        case 203...247:
            return "SW"
        case 248...292:
            return "W"
        case 293...337:
            return "NW"
        case 338...360:
            return "N"
        default:
            return ""
        }
    }
    
    
}
