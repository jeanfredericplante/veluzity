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
    
    @IBOutlet weak var speedLabel: WKInterfaceLabel!

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
        let speed = String(format: "%.0f",localizeSpeed(userLocation.speed, isMph: true))
        let font = UIFont.systemFontOfSize(50, weight: UIFontWeightThin)
        speedLabel.setAttributedText(speedText(speed, smallText: "mph", font: font, ratio: 0.3))
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
    
    func speedText(bigText: String, smallText: String,
        font: UIFont, ratio: CGFloat) -> NSAttributedString {
            var smallFontSize: CGFloat = round(font.pointSize * ratio)
            var smallFont = font.fontWithSize(smallFontSize)
            var bigAttrText = NSMutableAttributedString(string: bigText, attributes: [NSFontAttributeName: font])
            var smallAttrText = NSMutableAttributedString(string: "\n"+smallText, attributes: [NSFontAttributeName: smallFont])
            bigAttrText.appendAttributedString(smallAttrText)
            return bigAttrText
    }

}
