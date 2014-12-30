//
//  ViewController.swift
//  Speed
//
//  Created by Jean Frederic Plante on 12/27/14.
//  Copyright (c) 2014 Jean Frederic Plante. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, LocationUpdateDelegate {

    @IBOutlet weak var speedDisplay: UILabel!
    let userLocation = LocationModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLocation.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didUpdateLocation() {
        var speedInKmh = userLocation.speed * 3.6
        speedDisplay.text = NSString(format: "%.1f", speedInKmh)
    }
 
}

