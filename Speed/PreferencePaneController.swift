//
//  PreferencePaneController.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/10/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit
import VeluzityKit

@objc
protocol PreferencePaneControllerDelegate {
    optional func preferenceUpdated()
}


class PreferencePaneController: UIViewController, UIScrollViewDelegate {
    let defaults = Settings()


    var delegate: PreferencePaneControllerDelegate?
    
    
    struct Constants {
        static let speedResolution: Int = 5 // in mph or kmh, increment to determine max speed
        static let fontRatio: CGFloat = 0.6
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
    @IBOutlet weak var settingsScrollView: UIScrollView!
    @IBOutlet weak var scrollableSettings: UIView!
    @IBOutlet weak var versionLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePreferenceControls()
        setUISegmentedControlFonts()
        setScrollableView()
        setCurrentVersion()
        Flurry.logEvent("settings_viewdidload")
 
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
            return "Max speed: \(Settings.roundToNearest(increment: Constants.speedResolution, for_value: maxSpeedMph)) mph"
        } else {
            return "Max speed: \(Settings.roundToNearest(increment: Constants.speedResolution, for_value: maxSpeedKmh)) km/h"
        }
    }
    

    
    private func setUISegmentedControlFonts() {
        var attrSelected: Dictionary<NSObject, AnyObject>
        var attrNormal: Dictionary<NSObject, AnyObject>
        let nonSelectedColor = UIColor(red: 0.39, green: 0.40, blue: 0.43, alpha: 1)
        let selectedColor = UIColor.whiteColor()
        if let segFont = UIFont(name: "HelveticaNeue-Thin", size: 21.0) {
            attrSelected = [NSFontAttributeName: segFont, NSForegroundColorAttributeName:selectedColor]
            attrNormal = [NSFontAttributeName: segFont, NSForegroundColorAttributeName:nonSelectedColor]

        } else {
            attrSelected = [NSForegroundColorAttributeName : selectedColor]
            attrNormal = [NSForegroundColorAttributeName : nonSelectedColor]
        }
        UISegmentedControl.appearance().setTitleTextAttributes(attrSelected , forState: .Selected)
        UISegmentedControl.appearance().setTitleTextAttributes(attrNormal, forState: .Normal)

    }
    
    private func initializePreferenceControls() {
        speedPreferenceControl.selectedSegmentIndex = speedUnit.rawValue
        temperaturePreferenceControl.selectedSegmentIndex = temperatureUnit.rawValue
        speedSlider.minimumValue = Float(Params.PreferencePane.minMaxSpeedSlider)
        speedSlider.maximumValue = Float(Params.PreferencePane.maxMaxSpeedSlider)
        speedSlider.value = Float(defaults.maxSpeed)
        maxSpeedLabel.text = maxSpeedLabLocalized()
    }
    

    
    private func setScrollableView() -> Void {
        settingsScrollView.contentSize = CGSize(width: scrollableSettings.bounds.width, height: scrollableSettings.bounds.height)
        settingsScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        scrollableSettings.setTranslatesAutoresizingMaskIntoConstraints(false)
   
    }
    
    private func setCurrentVersion() -> Void {
        let version = " v" + UIApplicationUtils.getAppVersion()
        let font  = versionLabel.font
        let attributedTextForVersion =  SpeedViewsHelper.textWithTwoFontSizes("VELUZITY", smallText: version, font: font, ratio: Constants.fontRatio)
        versionLabel.attributedText = attributedTextForVersion
    }
 

    // MARK
    
    
}
