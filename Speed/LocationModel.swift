//
//  LocationModel.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/28/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

//import UIKit
import CoreLocation
// import AddressBook // AddressBook is deprecated/removed in newer iOS, but Contacts isn't used here explicitly anyway? Wait, CLPlacemark usage.

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
        self.locationManager.activityType = CLActivityType.other
        let currentStatus = CLLocationManager.authorizationStatus()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    public func speedInKmh() -> Double {
        return speed * 3.6
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = manager.location else {
            return
        }
        self.speed = location.speed
        self.coordinates = location.coordinate
        self.course = location.course
        self.getStreetName(location)
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
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.delegate?.didChangeLocationAuthorizationStatus(status: status)
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            self.delegate?.didChangeLocationAuthorizationStatus(status: status)
        @unknown default:
             break
        }
    }
    
 
    public func getStreetName(_ location: CLLocation) {
        locationGeoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            // Guard with let and boolean condition combined syntax changed in Swift 3
            guard let placemarks = placemarks, error == nil else {
                print("reverse location failed")
                return
            }
            
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
    
    
    public func getHeading() -> String {
        if course != nil && course! >= 0  {
            let cardHeading = getCardinalDirectionFromHeading(course!)
            return String(format: "%.0f° %@", self.course!, cardHeading) }
        else {
            return ""
        }
    }
    
  
    public func getCardinalDirection() -> String {
        if course != nil && course! >= 0  {
            return getCardinalDirectionFromHeading(self.course!)}
        else {
            return ""
        }
    }
    
    public func getHeadingDegrees() -> Double {
        if let c = course {
            return c
        } else {
             return 0
        }
    }
    
    public func getCardinalDirectionFromHeading(_ course: Double) -> String {
        let modCourse = Int(round(course.truncatingRemainder(dividingBy: 360)))
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
