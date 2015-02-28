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
    let defaults = Settings()
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
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        maxSpeedLabel.text = maxSpeedLabLocalized()
        delegate?.preferenceUpdated?()
        
    }
    
    @IBAction func speedSliderChanged(sender: UISlider) {
        defaults.maxSpeed = Double(sender.value)
        maxSpeedLabel.text = maxSpeedLabLocalized()
        delegate?.preferenceUpdated?()
        
    }
    
    
    var speedUnit: SpeedSegments {
        get {
            if defaults.isMph {
                return .Mph
            } else {
                return .Kmh
            }
        }
        set {
            switch newValue {
            case .Kmh:
                defaults.isMph = false
            default:
                defaults.isMph = true
            }
        }
    }
    
    var temperatureUnit: TemperatureSegments {
        get {
            if !defaults.isFahrenheit {
                return .Celsius
            } else {
                return .Fahrenheit
            }
        }
        set {
            switch newValue {
            case .Celsius:
                defaults.isFahrenheit = false
            default:
                defaults.isFahrenheit = true
            }
        }
    }
    
    
    
    private func maxSpeedLabLocalized() -> String {
        let maxSpeedMph =  defaults.maxSpeed * Params.Conversion.msToMph
        let maxSpeedKmh = defaults.maxSpeed * Params.Conversion.msToKmh
        
        if defaults.isMph {
            return "Max speed: \(roundToNearest(increment: 5, for_value: maxSpeedMph)) mph"
        } else {
            return "Max speed: \(roundToNearest(increment: 5, for_value: maxSpeedKmh)) km/h"
        }
    }
    
    private func roundToNearest(increment: Int = 5, for_value value: Double) -> Int {
        return  increment * Int (max(0, round(value / Double(increment))))
    }
    
    private func initializePreferenceControls() {
        speedPreferenceControl.selectedSegmentIndex = speedUnit.rawValue
        temperaturePreferenceControl.selectedSegmentIndex = temperatureUnit.rawValue
        speedSlider.minimumValue = Float(Params.PreferencePane.minMaxSpeedSlider)
        speedSlider.maximumValue = Float(Params.PreferencePane.maxMaxSpeedSlider)
        speedSlider.value = Float(defaults.maxSpeed)
        maxSpeedLabel.text = maxSpeedLabLocalized()
    }
    
    // MARK
    
    
}
