//
//  LocationModel.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/28/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBook

protocol LocationUpdateDelegate {
    func didUpdateLocation()
}

class LocationModel: NSObject, CLLocationManagerDelegate {
    var speed: Double = 0.0 // speed in m/s
    var altitude: Double = 0.0 // altitude in meters
    var coordinates: CLLocationCoordinate2D?
    var course: CLLocationDirection? // North/East/West/South
    let locationManager = CLLocationManager()
    let locationGeoCoder = CLGeocoder()
    var delegate: LocationUpdateDelegate?
    var streetName: String?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.activityType = CLActivityType.AutomotiveNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func speedInKmh() -> Double {
        return speed * 3.6
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.speed = manager.location.speed
        self.coordinates = manager.location.coordinate
        self.course = manager.location.course
        self.getStreetName(manager.location)
        println("speed (m/s):" + self.speed.description)
        self.delegate?.didUpdateLocation()
        
    }
    
    
    func getStreetName(location: CLLocation) {
        locationGeoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if error != nil {
                println("reverse location failed")
            } else {
                if placemarks.count > 0 {
                    var placemark: CLPlacemark = placemarks[0] as CLPlacemark
                    var newName = placemark.addressDictionary[kABPersonAddressStreetKey] as CFString?
                    if newName != nil {
                        self.streetName = newName
                    }
                    println("this is the placemark location \(self.streetName!)")
                    self.delegate?.didUpdateLocation()
                }
            }
        }
    }
    
    func getHeading()-> String {
        if course != nil {
            var cardHeading = getCardinalDirectionFromHeading(self.course!)
            return NSString(format: "%.0f° %@",self.course!, cardHeading) }
        else {
            return "--"
        }
    }
    
    func getCardinalDirectionFromHeading(course: Double) -> String {
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
            return "--"
        }
    }
    
    
}
