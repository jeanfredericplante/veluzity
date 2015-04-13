//
//  MeterView.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 4/5/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation
import WatchKit
import VeluzityKit
import CoreGraphics

class MeterView {
    struct Constants {
        static let maxDuration: NSTimeInterval = 0.75
        static let meterRadius: CGFloat = 50
        static let meterWidth: CGFloat = 5
        static let startAngleOffset: Double = 0
        static let maxDialSpeed: Double = 50
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
    
  
    
    var frameSize: CGSize {
        get {
            return viewBounds.size
        }
    }
    
    var viewBounds: CGRect
    var speed: Double = 0
    var transitionSpeed: Double = 30
    var speedUnit: WeatherIcon = .BrokenClouds
    
    
    init(bounds: CGRect) {
        viewBounds = bounds
    }
    
    
    /// The length that the Glance badge image will animate.
    var animationDuration: NSTimeInterval {
        return Constants.maxDuration
    }

    var meterBackgroundImage: UIImage {
        UIGraphicsBeginImageContextWithOptions(frameSize, false, 2.0)
        drawGradientInCurrentContext(for_speed: speed)
        drawProgressCircleInCurrentContext(for_speed: speed)
        drawSpeedTextInCurrentContext(for_speed: speed)
        let frame = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return frame
    }
    
    func drawGradientInCurrentContext(for_speed s: Double) {
        let colorspace = CGColorSpaceCreateDeviceRGB()
        if let (sc,ec) = speedToColorGradient(speed: s, maxTransitionSpeed: transitionSpeed)
        {
            let colors: CFArray = [sc.CGColor,ec.CGColor]
            let gradient = CGGradientCreateWithColors(colorspace, colors, [0,1])
            let startPoint = CGPoint(x: 0, y: 0)
            let endPoint = CGPoint(x: 0, y: frameSize.height)
            let ctx = UIGraphicsGetCurrentContext()
            CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, startPoint, endPoint, 0)
        }
    }
    
    func drawProgressCircleInCurrentContext(for_speed s: Double) {
        let path = CGPathCreateMutable()
        let c = UIGraphicsGetCurrentContext()
        let outerRadius = Constants.meterRadius
        let center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds))
        let speedPercentage = s/Constants.maxDialSpeed
        
        let startAngle =  CGFloat((3*M_PI_2) - Constants.startAngleOffset)
        let endAngle = startAngle - CGFloat((2*M_PI - 2*Constants.startAngleOffset) * speedPercentage)
        
        CGPathAddArc(path, nil, center.x, center.y, outerRadius, startAngle, endAngle, false)

        UIColor.whiteColor().set()
        CGContextAddPath(c, path)
        CGContextSetLineWidth(c, Constants.meterWidth)
        CGContextStrokePath(c)
    }
    
    func drawSpeedTextInCurrentContext(for_speed s: Double) {
        let c = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(c, 0.0, viewBounds.height)
        CGContextScaleCTM(c, 1.0, -1.0)
        
        let speed = String(format: "%.0f",localizeSpeed(s, isMph: true))
        let font = UIFont.systemFontOfSize(40)
        let x = CGRectGetMidX(viewBounds)
        let y = CGRectGetMidY(viewBounds)
        let attr = [NSFontAttributeName: font,
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        let attributedString = NSAttributedString(string: speed, attributes: attr)
        let line = CTLineCreateWithAttributedString(attributedString)

        CGContextSetTextPosition(c, x-attributedString.size().width/2, y)
        CTLineDraw(line, c)
     }
    
}
