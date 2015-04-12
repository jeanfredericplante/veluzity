//
//  AboutUsController.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 4/5/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation

class AboutUsController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!


    override func viewDidLoad() {
        Flurry.logEvent("aboutus_controller_load")
        versionLabel.text = "version "+UIApplicationUtils.getAppVersion()
    }
    
     
}
