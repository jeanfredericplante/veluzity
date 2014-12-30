//
//  LocationModel.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/28/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationUpdateDelegate {
    func didUpdateLocation()
}

class LocationModel: NSObject, CLLocationManagerDelegate {
    var speed: Double = 0.0 // speed in m/s
    var heading: String? // North/East/West/South
    let locationManager = CLLocationManager()
    var delegate: LocationUpdateDelegate?
    
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
        
        println("speed (m/s):" + self.speed.description)
        self.delegate?.didUpdateLocation()
        
    }

    
    
   
}
