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


class DashboardController: WKInterfaceController, LocationUpdateDelegate, SettingsDelegate {
    struct Constants {
        static let cacheBackgroundName = "background-"
        static let pregenerateAssetsInDocumentsFolder = true
        static let usePregeneratedAssets = true
        static let meterUpdateSpeedThreshold = 1 / Params.Conversion.msToKmh // (1km/h of speed threshold)
        static let animationDuration: NSTimeInterval = 2
    }
    
    @IBOutlet weak var meterGroup: WKInterfaceGroup!
    @IBOutlet weak var speedLabel: WKInterfaceLabel!

    let userLocation = LocationModel()
    let defaults = Settings()
    var lastMeterAnimationStartTime: NSDate?
    var lastMeterAnimationStartSpeed: Double?
    var lastMeterAnimationStopSpeed: Double?
    var currentAnimationDisplaySpeed: Double? {
        get {
            if let start = lastMeterAnimationStartTime {
                let elapsedTime = -start.timeIntervalSinceNow
                let isStillAnimating = elapsedTime < Constants.animationDuration
                if isStillAnimating {
                    if let start = lastMeterAnimationStartSpeed, stop = lastMeterAnimationStopSpeed {
                        let timeRatio = elapsedTime / Constants.animationDuration
                        println("time ratio :\(timeRatio)")
                        let interpSpeed = start + (stop - start) * timeRatio
                        return interpSpeed
                    }
                } else {
                    return lastMeterAnimationStopSpeed
                }
            }
            return nil
        }
    }
    var shouldUpdateMeterImage: Bool {
        get {
            return  abs(meterView.speed - userLocation.speed) > Constants.meterUpdateSpeedThreshold
        }
    }
    
    lazy var meterView: MeterView  = {
        let frameSize = WKInterfaceDevice.currentDevice().screenBounds
        return MeterView(bounds: frameSize)

    }()

    
    override func awakeWithContext(context: AnyObject?) {
        // Configure interface objects here.
        super.awakeWithContext(context)

        userLocation.delegate = self
        defaults.delegate = self
        meterView.speed = 0
        refreshSettingsDependents()
        pregenerateAssets()
        println("start caching images")
        cacheBackgroundImagesOnWatch()
        println("images cached")
        
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        println("will activate")
        let locationStatus = userLocation.authorizationStatus()
        presentAlertIfLocationAuthorizationNotAuthorized(locationStatus)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    // MARK: delegate methods
    
    func didUpdateLocation() {
        if shouldUpdateMeterImage {
            updateSpeed()
            let fromSpeed = currentAnimationDisplaySpeed ?? meterView.speed
            updateMeterImage(from_speed: fromSpeed, to_speed: userLocation.speed)
            meterView.speed = userLocation.speed
        }
    }
    
    func didUpdateSettings() {
        refreshSettingsDependents()
    }
    

    
    private func refreshSettingsDependents() {
        meterView.transitionSpeed = defaults.maxSpeedWatch
        
    }

    private func updateSpeed() {
        println("update speed")
        let speed = String(format: "%.0f",localizeSpeed(userLocation.speed, isMph: defaults.isMph) ?? 0)
        let speedUnit = defaults.isMph ? "mph" : "km/h"
        let font = UIFont.systemFontOfSize(50, weight: UIFontWeightThin)
        speedLabel.setAttributedText(speedText(speed, smallText: speedUnit, font: font, ratio: 0.3))
    }
    
    
    func didChangeLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        // TODO: handle auth change
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            userLocation.startUpdatingLocation()
        default:
            userLocation.stopUpdatingLocation()
            presentAlertIfLocationAuthorizationNotAuthorized(status)
        }
    }
    
    func updateMeterImage(from_speed start_speed: Double, to_speed new_speed: Double ) {
        
        var animRange: Range<Int>?
        var speed_is_increasing: Bool?
        refreshSettingsDependents()
        
        if start_speed < new_speed {
            speed_is_increasing = true
            lastMeterAnimationStartSpeed = start_speed; lastMeterAnimationStopSpeed = new_speed
            animRange = meterView.speedRangeToBackgroundImageRange(start_speed, stop_speed: new_speed)
        } else if start_speed > new_speed {
            speed_is_increasing = false
            lastMeterAnimationStartSpeed = new_speed; lastMeterAnimationStopSpeed = start_speed
            animRange = meterView.speedRangeToBackgroundImageRange(new_speed, stop_speed: start_speed)
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
    
    
    // MARK: private methods
    private func animateBackgroundForRange(r: Range<Int>, with_dial_increasing isAccelerating: Bool ) {
        let animRange = NSRange(r)
        let animDuration = NSTimeInterval((isAccelerating ? 1 : -1) * Constants.animationDuration)
        meterGroup.setBackgroundImageNamed(Constants.cacheBackgroundName)
        lastMeterAnimationStartTime = NSDate(timeInterval: 0, sinceDate: NSDate())
        meterGroup.startAnimatingWithImagesInRange(animRange, duration: animDuration, repeatCount: 1)
    }
    
    private func cacheBackgroundImagesOnWatch() {
        if !Constants.usePregeneratedAssets {
            let device =   WKInterfaceDevice.currentDevice()
            let imageSet = meterView.createAssetsForCaching()
            let backgroundAnimation = UIImage.animatedImageWithImages(imageSet, duration: NSTimeInterval(1.0))
            device.removeAllCachedImages()
            device.addCachedImage(backgroundAnimation, name: Constants.cacheBackgroundName)
        }
    }
    
    private func saveAssetsInCache(imageArray: [UIImage]?) {
        if let allImages = imageArray {
            for (index,backgroundImage) in enumerate(allImages) {
                if let imageData = UIImagePNGRepresentation(backgroundImage) {
                    let fileManager = NSFileManager()
                    if let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as? NSURL {
                        let filename = Constants.cacheBackgroundName + "\(index)@2x.png"
                        let url = docsDir.URLByAppendingPathComponent(filename)
                        if let path = url.absoluteString {
                            if imageData.writeToURL(url, atomically: true) {
                                println("saved successfully to \(path)")
                            }
                        }
                    }

                }
            }
        }
        
    }
    
    private func pregenerateAssets() {
        if Constants.pregenerateAssetsInDocumentsFolder {
            println("saving images in cache")
            let imageSet = meterView.createAssetsForCaching()
            saveAssetsInCache(imageSet)
        }

    }
    
    private func presentAlertIfLocationAuthorizationNotAuthorized(status: CLAuthorizationStatus) {
        // present controller modally
        switch status {
        case .Denied, .Restricted:
            self.userLocation.stopUpdatingLocation()
            presentControllerWithName("LocationAlert", context: self)
            default:
            break
        }


    }

 
}
