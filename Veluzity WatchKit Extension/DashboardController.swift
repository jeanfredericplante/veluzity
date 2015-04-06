//
//  InterfaceController.swift
//  Veluzity WatchKit Extension
//
//  Created by Jean Frederic Plante on 4/1/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import WatchKit
import Foundation
import VeluzityKit


class DashboardController: WKInterfaceController, LocationUpdateDelegate {

    @IBOutlet weak var speedLabel: WKInterfaceLabel!
    @IBOutlet weak var speedUnitLabel: WKInterfaceLabel!
    
    @IBOutlet weak var meterGroup: WKInterfaceGroup!
    
    @IBOutlet weak var meterImage: WKInterfaceImage!
    let userLocation = LocationModel()

    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        userLocation.delegate = self
 
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    private func updateSpeed() {
        let speed = localizeSpeed(userLocation.speed, isMph: true)
        speedLabel.setText(String(format: "%.0f", speed))
    }
    
    func didUpdateLocation() {
        updateSpeed()
        updateMeterImage()
    }
    
    func updateMeterImage() {
        let frameSize = WKInterfaceDevice.currentDevice().screenBounds
        let meterView = MeterView(meterSize: CGSize(width: frameSize.width, height: frameSize.height))
        meterGroup.setBackgroundImage(meterView.meterBackgroundImage)
        
    }

}
