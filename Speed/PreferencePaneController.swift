//
//  PreferencePaneController.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/10/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

@objc
protocol PreferencePaneControllerDelegate {
    optional func preferenceUpdated()
}


class PreferencePaneController: UIViewController {
    var defaults: NSUserDefaults!
    var delegate: PreferencePaneControllerDelegate?
    
    enum SpeedSegments: Int {
        case Mph = 0
        case Kmh = 1
    }
    
    enum TemperatureSegments: Int {
        case Fahrenheit = 0
        case Celsius = 1
    }
    


    @IBOutlet weak var temperaturePreferenceControl: UISegmentedControl!
    @IBOutlet weak var speedPreferenceControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults = NSUserDefaults.standardUserDefaults()
        initializePreferenceControls()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Buttons
    @IBAction func temperaturePressed(sender: UISegmentedControl) {
        if let temp_unit = TemperatureSegments(rawValue: sender.selectedSegmentIndex) {
            temperatureUnit = temp_unit
        }
        delegate?.preferenceUpdated?()
    }
    
    @IBAction func speedPressed(sender: UISegmentedControl) {
        if let speed_unit = SpeedSegments(rawValue: sender.selectedSegmentIndex) {
            speedUnit = speed_unit
        }
        delegate?.preferenceUpdated?()

    }
  
    
    func setPreferenceAsMetric() {
        defaults.setBool(false, forKey: "isMph")
        defaults.setBool(true, forKey: "isCelsius")
        defaults.synchronize()
    }
    
    func setPreferenceAsImperial() {
        defaults.setBool(true, forKey: "isMph")
        defaults.setBool(false, forKey: "isCelsius")
        defaults.synchronize()
    }
    
  
    var speedUnit: SpeedSegments {
        get {
            if defaults.boolForKey("isMph") {
                return .Mph
            } else {
                return .Kmh
            }
        }
        set {
            switch newValue {
            case .Kmh:
                defaults.setBool(false, forKey: "isMph")
            default:
                defaults.setBool(true, forKey: "isMph")
            }
            defaults.synchronize()
        }
    }
    
    var temperatureUnit: TemperatureSegments {
        get {
            if defaults.boolForKey("isCelsius") {
                return .Celsius
            } else {
                return .Fahrenheit
            }
        }
        set {
            switch newValue {
            case .Celsius:
                defaults.setBool(true, forKey: "isCelsius")
            default:
                defaults.setBool(false, forKey: "isCelsius")
            }
            defaults.synchronize()
        }
    }
    
    
    private func initializePreferenceControls() {
        speedPreferenceControl.selectedSegmentIndex = speedUnit.rawValue
        temperaturePreferenceControl.selectedSegmentIndex = temperatureUnit.rawValue
    }

    
}
