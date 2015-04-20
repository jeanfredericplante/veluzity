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
    struct Constants {
        static let cacheBackgroundName = "background_"
    }
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
        meterView.speed = 0
        println("start caching images")
        cacheBackgroundImagesOnWatch()
        println("images cached")
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
        let speed = String(format: "%.0f",localizeSpeed(userLocation.speed, isMph: true) ?? 0)
        let font = UIFont.systemFontOfSize(50, weight: UIFontWeightThin)
        speedLabel.setAttributedText(speedText(speed, smallText: "mph", font: font, ratio: 0.3))
    }
    
    func didUpdateLocation() {
        if meterView.speed != userLocation.speed {
            updateSpeed()
            updateMeterImage(from_speed: meterView.speed, to_speed: userLocation.speed)
            meterView.speed = userLocation.speed

        }
    }
    
    func didChangeLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        // TODO: handle auth change
    }
    
    func updateMeterImage(from_speed start_speed: Double, to_speed new_speed: Double ) {
        
        var animRange: Range<Int>?
        var speed_is_increasing: Bool?
        
        if start_speed < new_speed {
            speed_is_increasing = true
            animRange = MeterView.speedRangeToBackgroundImageRange(start_speed, stop_speed: new_speed)
        } else if start_speed > new_speed {
            speed_is_increasing = false
            animRange = MeterView.speedRangeToBackgroundImageRange(new_speed, stop_speed: start_speed)
        }
        if let r = animRange, b = speed_is_increasing {
            animateBackgroundForRange(r, with_dial_increasing: b)
            meterView.speed = userLocation.speed
        }

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
    
    private func cacheBackgroundImagesOnWatch() {
        let device =   WKInterfaceDevice.currentDevice()
        let imageSet = meterView.createAssetsForCaching()
        let backgroundAnimation = UIImage.animatedImageWithImages(imageSet, duration: NSTimeInterval(1.0))
        device.removeAllCachedImages()
        device.addCachedImage(backgroundAnimation, name: Constants.cacheBackgroundName)
    }
    
    private func animateBackgroundForRange(r: Range<Int>, with_dial_increasing isAccelerating: Bool ) {
        let animRange = NSRange(r)
        let animDuration = NSTimeInterval((isAccelerating ? 1 : -1) * 2)
        meterGroup.setBackgroundImageNamed(Constants.cacheBackgroundName)
        meterGroup.startAnimatingWithImagesInRange(animRange, duration: animDuration, repeatCount: 1)
    }
    
    

}
