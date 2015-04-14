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

    @IBOutlet weak var meterGroup: WKInterfaceGroup!
    
    @IBOutlet weak var meterImage: WKInterfaceImage!
    let userLocation = LocationModel()
    lazy var meterView: MeterView  = {
        let frameSize = WKInterfaceDevice.currentDevice().screenBounds
        let centerX = CGRectGetMidX(frameSize)
        let centerY = CGRectGetMidY(frameSize)
        let width = min(frameSize.width, frameSize.height)
        return MeterView(bounds: CGRectMake(centerX-width/2, centerY-frameSize.height/2, width, width))
    }()

    
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
//        speedLabel.setText(String(format: "%.0f", speed))
    }
    
    func didUpdateLocation() {
        updateSpeed()
        updateMeterImage()
    }
    
    func didChangeLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        // TODO: handle auth change
    }
    
    func updateMeterImage() {
        meterView.speed = userLocation.speed
        meterGroup.setBackgroundImage(meterView.meterBackgroundImage)
        
    }

}
