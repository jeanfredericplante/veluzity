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
        static let pregenerateAssetsInDocumentsFolder = false
        static let usePregeneratedAssets = true
        static let meterUpdateSpeedThreshold = 1 / Params.Conversion.msToKmh // (1km/h of speed threshold)
        static let animationDuration: TimeInterval = 2
    }
    
    @IBOutlet weak var meterGroup: WKInterfaceGroup!
    @IBOutlet weak var speedLabel: WKInterfaceLabel!
    @IBOutlet weak var speedUnit: WKInterfaceLabel!
    
    let userLocation = LocationModel()
    let defaults = Settings()
    var lastMeterAnimationStartTime: Date?
    var lastMeterAnimationStartSpeed: Double?
    var lastMeterAnimationStopSpeed: Double?
    var currentAnimationDisplaySpeed: Double? {
        get {
            if let start = lastMeterAnimationStartTime {
                let elapsedTime = -start.timeIntervalSinceNow
                let isStillAnimating = elapsedTime < Constants.animationDuration
                if isStillAnimating {
                    if let start = lastMeterAnimationStartSpeed, let stop = lastMeterAnimationStopSpeed {
                        let timeRatio = elapsedTime / Constants.animationDuration
                        print("time ratio :\(timeRatio), start:\(lastMeterAnimationStartSpeed), stop:\(lastMeterAnimationStopSpeed)")
                        let interpSpeed = start + (stop - start) * timeRatio
                        print("interpSpeed:\(interpSpeed)")
                        return interpSpeed
                    }
                } else {
                    print("animation complete, speed:\(lastMeterAnimationStopSpeed)")
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
        let frameSize = WKInterfaceDevice.current().screenBounds
        return MeterView(bounds: frameSize)
        
    }()
    
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        super.awake(withContext: context)
        // FlurryWatch.logWatchEvent("Veluzity dashboard event!") // Assuming FlurryWatch interface is updated or we comment it out if not available
        
        
        userLocation.delegate = self
        defaults.delegate = self
        meterView.speed = 0
        refreshSettingsDependents()
        if Constants.pregenerateAssetsInDocumentsFolder {
            pregenerateAssets()
        }
        if !Constants.usePregeneratedAssets {
            cacheBackgroundImagesOnWatch()
        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("will activate")
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
            if currentAnimationDisplaySpeed == nil {
                print("no current display speed, fall back on speed \(meterView.speed)")
            }
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
        let speed = String(format: "%.0f",localizeSpeed(speed: userLocation.speed, isMph: defaults.isMph) ?? 0)
        let unit = defaults.isMph ? "mph" : "km/h"
        speedLabel.setText(speed)
        speedUnit.setText(unit)
    }
    
    
    func didChangeLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        // TODO: handle auth change
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
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
        lastMeterAnimationStartSpeed = start_speed; lastMeterAnimationStopSpeed = new_speed;
        if start_speed < new_speed {
            speed_is_increasing = true
            animRange = meterView.speedRangeToBackgroundImageRange(start_speed: start_speed, stop_speed: new_speed)
        } else if start_speed > new_speed {
            speed_is_increasing = false
            animRange = meterView.speedRangeToBackgroundImageRange(start_speed: new_speed, stop_speed: start_speed)
        }
        if let r = animRange, let b = speed_is_increasing {
            animateBackgroundForRange(r: r, with_dial_increasing: b)
            meterView.speed = userLocation.speed
        }
        
    }
    
    func speedText(bigText: String, smallText: String,
                   font: UIFont, ratio: CGFloat) -> NSAttributedString {
        let smallFontSize: CGFloat = round(font.pointSize * ratio)
        let smallFont = font.withSize(smallFontSize)
        let bigAttrText = NSMutableAttributedString(string: bigText, attributes: [NSAttributedString.Key.font: font])
        let smallAttrText = NSMutableAttributedString(string: "\n"+smallText, attributes: [NSAttributedString.Key.font: smallFont])
        bigAttrText.append(smallAttrText)
        return bigAttrText
    }
    
    
    // MARK: private methods
    private func animateBackgroundForRange(r: Range<Int>, with_dial_increasing isAccelerating: Bool ) {
        let animRange = NSRange(r)
        let animDuration = TimeInterval((isAccelerating ? 1 : -1) * Constants.animationDuration)
        meterGroup.setBackgroundImageNamed(Constants.cacheBackgroundName)
        lastMeterAnimationStartTime = Date(timeInterval: 0, since: Date())
        meterGroup.startAnimatingWithImages(in: animRange, duration: animDuration, repeatCount: 1)
    }
    
    private func cacheBackgroundImagesOnWatch() {
        print("cache images on the watch")
        let device =   WKInterfaceDevice.current()
        let imageSet = meterView.createAssetsForCaching()
        guard let backgroundAnimation = UIImage.animatedImage(with: imageSet, duration: TimeInterval(1.0)) else {
            return
        }
        device.removeAllCachedImages()
        device.addCachedImage(backgroundAnimation, name: Constants.cacheBackgroundName)
    }
    
    private func saveAssetsInCache(imageArray: [UIImage]?) {
        if let allImages = imageArray {
            for (index,backgroundImage) in allImages.enumerated() {
                if let imageData = backgroundImage.pngData() {
                    let fileManager = FileManager.default
                    if let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                        
                        let filename = Constants.cacheBackgroundName + "\(index)@2x.png"
                        let url = docsDir.appendingPathComponent(filename)
                        let path = url.absoluteString
                        do {
                            try imageData.write(to: url, options: .atomic)
                            print("saved successfully to \(path)")
                        } catch {
                            print("failed to save to \(path)")
                        }
                    }
                    
                }
            }
        }
        
    }
    
    private func pregenerateAssets() {
        print("saving pregenerated assets in documents folder")
        let imageSet = meterView.createAssetsForCaching()
        saveAssetsInCache(imageArray: imageSet)
        
    }
    
    private func presentAlertIfLocationAuthorizationNotAuthorized(_ status: CLAuthorizationStatus) {
        // present controller modally
        switch status {
        case .denied, .restricted:
            self.userLocation.stopUpdatingLocation()
            presentController(withName: "LocationAlert", context: self)
        default:
            break
        }
        
        
    }
    
    
}
