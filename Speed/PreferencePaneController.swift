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
    var isMph: Bool {
        get { return defaults.boolForKey("isMph") }
        set { defaults.setBool(newValue, forKey: "isMph") }
    }
    var isFahrenheit: Bool {
        get { return !defaults.boolForKey("isCelsius") }
        set { defaults.setBool(!newValue, forKey: "isCelsius") }
    }
    var maxSpeed: Double {
        get { return defaults.doubleForKey("maxSpeed") }
        set { defaults.setDouble(newValue, forKey: "maxSpeed") }
    }

    
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
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    
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
  
    @IBAction func speedSliderChanged(sender: UISlider) {
    }
    
    func setPreferenceAsMetric() {
        isMph = false ; isFahrenheit = false
        defaults.synchronize()
    }
    
    func setPreferenceAsImperial() {
        isMph = true ; isFahrenheit = true
        defaults.synchronize()
    }
    
  
    var speedUnit: SpeedSegments {
        get {
            if isMph {
                return .Mph
            } else {
                return .Kmh
            }
        }
        set {
            switch newValue {
            case .Kmh:
                isMph = false
            default:
                isMph = true
            }
            defaults.synchronize()
        }
    }
    
    var temperatureUnit: TemperatureSegments {
        get {
            if !isFahrenheit {
                return .Celsius
            } else {
                return .Fahrenheit
            }
        }
        set {
            switch newValue {
            case .Celsius:
                isFahrenheit = false
            default:
                isFahrenheit = true
            }
            defaults.synchronize()
        }
    }
    
    
    private func initializePreferenceControls() {
        speedPreferenceControl.selectedSegmentIndex = speedUnit.rawValue
        temperaturePreferenceControl.selectedSegmentIndex = temperatureUnit.rawValue
    }
    
    // MARK

    
}
