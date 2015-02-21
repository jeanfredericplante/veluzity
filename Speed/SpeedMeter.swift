//
//  SpeedMeter.swift
//  CircleProgressView
//
//  Created by Jean Frederic Plante on 1/19/15.
//  Copyright (c) 2015 Eric Rolf. All rights reserved.
//

import UIKit

extension UIBezierPath {
    func createArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, width: CGFloat){
        self.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        self.addArcWithCenter(center, radius: radius-width,  startAngle: endAngle, endAngle: startAngle, clockwise: false)
        self.closePath()
    }
}


@IBDesignable class SpeedMeter: UIView {
    
    
    // MARK: Declare inspectable variables

    @IBInspectable var speed: Double = 0.0 {
        didSet { setNeedsDisplay() }
    }
    
    
    @IBInspectable var trackImage: UIImage? {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var trackColor: UIColor = UIColor.whiteColor() {
        didSet { setNeedsDisplay() }
    }

    
    @IBInspectable var trackBorderWidth: CGFloat = 6 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var startAngle: Double = 30.0 {
        // start angle referenced from the south of the circle
        didSet { setNeedsDisplay() }
    }
 
    @IBInspectable var minimumSpeed: Double = 0.0 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var maximumSpeed: Double = 120.0 {
        didSet { setNeedsDisplay() }
    }
    
    // Speedmeter structure
    struct Meter {
        var startAngleRadians: CGFloat
        var maximumAngleRadians: CGFloat
        var speedAngleRadians: CGFloat
        var center: CGPoint
        var radius: CGFloat
        
        var maxAngleRadians: CGFloat  {
            get { return startAngleRadians+maximumAngleRadians }
        }
    }
    
    var sm = Meter(startAngleRadians: 0, maximumAngleRadians: 0, speedAngleRadians: 0, center: CGPoint(), radius: 0)
    
    
    // MARK: override methods
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupMeter()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupMeter()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        let innerRect = CGRectInset(rect, trackBorderWidth, trackBorderWidth)
 
        // start angle referenced from the south of the circle
        let startAngleRadians = CGFloat(degreesToRadians(startAngle+90))
        let maximumAngleRadians = degreesToRadians(360 - 2*startAngle)
        let speedCurve = UIBezierPath()
        let speedBackground = UIBezierPath()
        let speedRect = CGRectMake(innerRect.minX, innerRect.minY, CGRectGetWidth(innerRect), CGRectGetHeight(innerRect))
        let centerCurve = CGPoint(x:speedRect.midX, y: speedRect.midY)
        let radius = speedRect.width / 2.0
        
        // there is a minimum for the meter, and set the max to what can be hit
        var displaySpeed = min(max(minimumSpeed, speed), maximumSpeed)
        
        let speedAngle = CGFloat(displaySpeed / maximumSpeed) * maximumAngleRadians
        let endAngleRadians = CGFloat(startAngleRadians+speedAngle)
        let maxAngleRadians = CGFloat(startAngleRadians+maximumAngleRadians)
        
        // create background arc
        speedBackground.createArc(centerCurve, radius: radius, startAngle: startAngleRadians, endAngle: maxAngleRadians, width: trackBorderWidth)
        if trackImage == nil {
            trackColor.setFill()
            speedBackground.fillWithBlendMode(kCGBlendModeNormal, alpha: 0.1)
        } else {
            speedBackground.addClip()
            trackImage!.drawInRect(innerRect, blendMode: kCGBlendModeNormal, alpha: 0.1)
        }
        
        // create speed arc        
        speedCurve.createArc(centerCurve, radius: radius, startAngle: startAngleRadians, endAngle: endAngleRadians, width: trackBorderWidth)
        if trackImage == nil {
            trackColor.setFill()
            speedCurve.fill()
        } else {
            speedCurve.addClip()
            trackImage!.drawInRect(innerRect)
        }
        
    }
    
    
    
    func setupMeter() {
        let innerRect = CGRectInset(self.bounds, trackBorderWidth, trackBorderWidth)
        sm.startAngleRadians = CGFloat(degreesToRadians(startAngle+90))
        sm.maximumAngleRadians = degreesToRadians(360 - 2*startAngle)
        sm.center = CGPoint(x:innerRect.midX, y: innerRect.midY)
        sm.radius = innerRect.width / 2.0
        sm.speedAngleRadians = 0
        
        updateSpeed()
    }
    
    func updateSpeed() {
        // there is a minimum for the meter, and set the max to what can be hit
        let displaySpeed = min(max(minimumSpeed, speed), maximumSpeed)
        let speedAngle = CGFloat(displaySpeed / maximumSpeed) * sm.maximumAngleRadians
        sm.speedAngleRadians  = CGFloat(sm.startAngleRadians+speedAngle)
    }
    
    func backgroundMeterPath() -> UIBezierPath {
        return UIBezierPath()
    }
    
    
    
    func setSpeedWithAnimation(speed: Double) {
        
    }
    

    func degreesToRadians(degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180.0)
    }
}
