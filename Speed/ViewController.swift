//
//  ViewController.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/27/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var speedDisplay: UILabel!
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var speed = manager.location.speed
        var speedInKmh = speed * 3.6
    
        println("speed:" + speed.description)
        println("speed (km/h):" + speedInKmh.description)
        
        speedDisplay.text = NSString(format: "%.1f", speedInKmh)
    }

}

