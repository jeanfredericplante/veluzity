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
            return NSString(format: "%.0f°",self.course!) }
        else {
            return "--"
        }
    }
    
    
}
