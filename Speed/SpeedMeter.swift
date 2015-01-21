//
//  SpeedMeter.swift
//  CircleProgressView
//
//  Created by Jean Frederic Plante on 1/19/15.
//  Copyright (c) 2015 Eric Rolf. All rights reserved.
//

import UIKit

@IBDesignable class SpeedMeter: UIView {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    internal struct Constants {
        var contentView:UIView = UIView()
        var contentContainer:UIView = UIView()
    }
    
    let constants = Constants()
    
    @IBInspectable var contentView: UIView {
        return self.constants.contentView
    }
    
    @IBInspectable var speed: Double = 0.0 {
        didSet { setNeedsDisplay() }
    }
    

    
    @IBInspectable var trackImage: UIImage? {
        didSet { setNeedsDisplay() }
    }

    
    @IBInspectable var trackBorderWidth: CGFloat = 15 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var startAngle: Double = 30.0 {
        // start angle referenced from the south of the circle
        didSet { setNeedsDisplay() }
    }
 
    @IBInspectable var minimumSpeed: Double = 1.0 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var maximumSpeed: Double = 120.0 {
        didSet { setNeedsDisplay() }
    }
    
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubview(contentView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(contentView)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        let innerRect = CGRectInset(rect, trackBorderWidth, trackBorderWidth)
 
        // start angle referenced from the south of the circle
        let startAngleRadians = CGFloat(degreesToRadians(startAngle+90))
        let maximumAngleRadians = degreesToRadians(360 - 2*startAngle)
        let speedCurve = UIBezierPath()
        let speedRect = CGRectMake(innerRect.minX, innerRect.minY, CGRectGetWidth(innerRect), CGRectGetHeight(innerRect))
        let centerCurve = CGPoint(x:speedRect.midX, y: speedRect.midY)
        let radius = speedRect.width / 2.0
        
        // there is a minimum for the meter, and set the max to what can be hit
        var displaySpeed = min(max(minimumSpeed, speed), maximumSpeed)
        
        let speedAngle = CGFloat(displaySpeed / maximumSpeed) * maximumAngleRadians
        let endAngleRadians = CGFloat(startAngleRadians+speedAngle)
        
        speedCurve.addArcWithCenter(centerCurve, radius: radius, startAngle: startAngleRadians, endAngle: endAngleRadians, clockwise: true)
        speedCurve.addArcWithCenter(centerCurve, radius: radius-trackBorderWidth,  startAngle: endAngleRadians, endAngle: startAngleRadians, clockwise: false)
        speedCurve.closePath()
        speedCurve.addClip()
        
        trackImage!.drawInRect(innerRect)

//        speedCurve.lineWidth = 3
//        UIColor.whiteColor().setStroke()
//        speedCurve.stroke()
        
    }
    
    func degreesToRadians(degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180.0)
    }
}
