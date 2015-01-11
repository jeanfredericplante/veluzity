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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults = NSUserDefaults.standardUserDefaults()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Buttons
    @IBAction func metricPressed(sender: AnyObject) {
        setPreferenceAsMetric()
        delegate?.preferenceUpdated?()
    }
  
    @IBAction func imperialPressed(sender: AnyObject) {
        setPreferenceAsImperial()
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

    
}
