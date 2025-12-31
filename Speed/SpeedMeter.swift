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
        self.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        self.addArc(withCenter: center, radius: radius-width,  startAngle: endAngle, endAngle: startAngle, clockwise: false)
        self.close()
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
    
    @IBInspectable var trackColor: UIColor = UIColor.white {
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupMeter()
        speedBackgroundPath = backgroundMeterPath()
        setMeterPath(meter: speedCurveLayer)
        if speedCurveLayer.superlayer == nil {
            self.layer.addSublayer(speedCurveLayer)
        }

        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // update / create background path
        trackColor.setStroke()
        speedBackgroundPath.stroke(with: .normal, alpha: 0.1)
        
        // updated speed
        updateSpeed()
 
    }
    
    
    
    func setupMeter(rect: CGRect? = nil) {
        var innerRect: CGRect
        if let meterZone = rect {
             innerRect = meterZone.insetBy(dx: trackBorderWidth, dy: trackBorderWidth)
        } else {
             innerRect = self.bounds.insetBy(dx: trackBorderWidth, dy: trackBorderWidth)
        }
        sm.startAngleRadians = CGFloat(degreesToRadians(degrees: startAngle + 90))
        sm.maximumAngleRadians = CGFloat(sm.startAngleRadians + degreesToRadians(degrees: 360 - 2*startAngle))
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
        setNeedsDisplay()
    }
    
    func backgroundMeterPath() -> UIBezierPath {
        let meterPath = UIBezierPath()
        meterPath.lineWidth = trackBorderWidth
        meterPath.addArc(withCenter: sm.center, radius: sm.radius, startAngle: sm.startAngleRadians, endAngle: sm.maximumAngleRadians, clockwise: true)
        return meterPath
    }
    
    func setMeterPath(meter: CAShapeLayer) -> Void {
        meter.path = speedBackgroundPath.cgPath
        meter.fillColor = UIColor.clear.cgColor
        meter.lineWidth = trackBorderWidth
        meter.strokeStart = 0
        meter.strokeEnd = 0
        meter.strokeColor = trackColor.cgColor

    }
    
    
    func degreesToRadians(degrees: Double) -> CGFloat {
        return CGFloat(degrees * Double.pi / 180.0)
    }
}
