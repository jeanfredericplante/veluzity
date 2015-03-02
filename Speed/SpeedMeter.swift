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
    struct Constants {
        static let animDuration = CFTimeInterval(3)
    }
    
    // MARK: Declare inspectable variables

    @IBInspectable var speed: Double = 0.0 {
        didSet { updateSpeed() }
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

    @IBInspectable var maximumSpeed: Double = 48.0 {
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
    var speedBackgroundPath = UIBezierPath()
    var speedCurveLayer = CAShapeLayer()

    
    
    // MARK: override methods
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupMeter(rect: frame)

    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupMeter()
        speedBackgroundPath = backgroundMeterPath()
        speedCurveLayer = speedMeterPath()
        self.layer.addSublayer(speedCurveLayer)

    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        // update / create background path
        trackColor.setStroke()
        speedBackgroundPath.strokeWithBlendMode(kCGBlendModeNormal, alpha: 0.1)
        
        // updated speed
        updateSpeed()
 
    }
    
    
    
    func setupMeter(rect: CGRect? = nil) {
        var innerRect: CGRect
        if let meterZone = rect {
             innerRect = CGRectInset(meterZone, trackBorderWidth, trackBorderWidth)
        } else {
             innerRect = CGRectInset(self.bounds, trackBorderWidth, trackBorderWidth)
        }
        sm.startAngleRadians = CGFloat(degreesToRadians(startAngle + 90))
        sm.maximumAngleRadians = CGFloat(sm.startAngleRadians + degreesToRadians(360 - 2*startAngle))
        sm.center = CGPoint(x:innerRect.midX, y: innerRect.midY)
        sm.radius = innerRect.width / 2.0
        sm.speedAngleRadians = 0
        
       
        }
    
    func updateSpeed() {
        // there is a minimum for the meter, and set the max to what can be hit
        CATransaction.setAnimationDuration(Constants.animDuration)
        let displaySpeed = min(max(minimumSpeed, speed), maximumSpeed)
        let strokeEnd = CGFloat(displaySpeed / maximumSpeed)
        speedCurveLayer.strokeEnd = strokeEnd
    }
    
    func backgroundMeterPath() -> UIBezierPath {
        let meterPath = UIBezierPath()
        meterPath.lineWidth = trackBorderWidth
        meterPath.addArcWithCenter(sm.center, radius: sm.radius, startAngle: sm.startAngleRadians, endAngle: sm.maximumAngleRadians, clockwise: true)
        return meterPath
    }
    
    func speedMeterPath() -> CAShapeLayer {
        var context = UIGraphicsGetCurrentContext()
        let speedArc = CAShapeLayer()
        speedArc.path = speedBackgroundPath.CGPath
        speedArc.fillColor = UIColor.clearColor().CGColor
        speedArc.lineWidth = trackBorderWidth
        speedArc.strokeStart = 0
        speedArc.strokeEnd = 0
        speedArc.strokeColor = trackColor.CGColor
        return speedArc
    }
    
    
    func degreesToRadians(degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180.0)
    }
}
