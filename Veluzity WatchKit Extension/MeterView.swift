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
        static let numberOfMeterViewAssets = 360
        static let maxDuration: NSTimeInterval = 0.75
        static let meterRadius: CGFloat = 70
        static let gradientClipWidth: CGFloat = 140
        static let meterWidth: CGFloat = 10
        static let startAngleOffset: Double = M_PI/10
        static let maxDialSpeedNormalized: Double = SpeedGradientConstants.speedAtRedTransition / Params.SpeedMeter.maxSpeedFractionOfDial // "normalized" to transition at red, needs refactor to be normalized to 0-1
        static let backgroundGradientIsCircular = false
        static let watch38mmBackgroundSize = CGSize(width: 272, height: 340)
        static let watch42mmBackgroundSize = CGSize(width: 312, height: 390)

    }
  
    var frameSize: CGSize {
        get {
            return viewBounds.size
        }
    }
    
    var viewBounds: CGRect
    var speed: Double = 0
    var transitionSpeed: Double = SpeedGradientConstants.speedAtRedTransition
    
    
    init(bounds: CGRect) {
        viewBounds = bounds
    }
    
    
    // MARK: Creation of the pregenerated background and progress meter images
    var animationDuration: NSTimeInterval {
        return Constants.maxDuration
    }

    var meterBackgroundImage: UIImage {
        let frame = createBackground(for_speed: speed, with_size: frameSize)
        return frame
    }
    
    func drawGradientInCurrentContext(for_speed s: Double) {
        let colorspace = CGColorSpaceCreateDeviceRGB()
        if let (sc,ec) = speedToColorGradient(speed: s, maxTransitionSpeed: transitionSpeed)
        {
            let ctx = UIGraphicsGetCurrentContext()
            let colors: CFArray = [sc.CGColor,ec.CGColor]
            let xMin = CGRectGetMidX(viewBounds) - Constants.gradientClipWidth/2
            let yMin = CGRectGetMidY(viewBounds) - Constants.gradientClipWidth/2
            CGContextAddEllipseInRect(ctx, CGRectMake(xMin, yMin, Constants.gradientClipWidth, Constants.gradientClipWidth))
            CGContextClip(ctx)
            let gradient = CGGradientCreateWithColors(colorspace, colors, [0,1])
            let startPoint = CGPoint(x: 0, y: 0)
            let endPoint = CGPoint(x: 0, y: frameSize.height)
            CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0)
        }
    }
    
    func drawProgressCircleInCurrentContext(for_speed s: Double) {
        let path = CGPathCreateMutable()
        let c = UIGraphicsGetCurrentContext()

        let outerRadius = Constants.meterRadius - Constants.meterWidth/2
        let center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds))
        let speedPercentage = speedFractionOfMax(s)
        
        let startAngle =  CGFloat((3*M_PI_2) - Constants.startAngleOffset)
        let endAngle = startAngle - CGFloat((2*M_PI - 2*Constants.startAngleOffset) * speedPercentage)
        
        CGPathAddArc(path, nil, center.x, center.y, outerRadius, startAngle, endAngle, true)

        UIColor.whiteColor().set()
        CGContextAddPath(c, path)
        CGContextSetLineWidth(c, Constants.meterWidth)
        CGContextSetLineCap(c, kCGLineCapRound)
        CGContextStrokePath(c)
    }
    
    func drawSpeedTextInCurrentContext(for_speed s: Double) {
        let c = UIGraphicsGetCurrentContext()
        let speed = String(format: "%.0f",localizeSpeed(s, isMph: true) ?? 0)
        let font = UIFont.systemFontOfSize(50)
        let x = CGRectGetMidX(viewBounds)
        let y = CGRectGetMidY(viewBounds)
        let attr = [NSFontAttributeName: font,
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        let attributedString = NSAttributedString(string: speed, attributes: attr)
        let line = CTLineCreateWithAttributedString(attributedString)

        CGContextSetTextPosition(c, x-attributedString.size().width/2, y-attributedString.size().height/4)
        CTLineDraw(line, c)
     }
    
    func setAxisOrientation() {
        let c = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(c, 0.0, viewBounds.height)
        CGContextScaleCTM(c, 1.0, -1.0)
    }
    
    func createAssetsForCaching() -> [UIImage] {
        var array_assets: [UIImage] = []
        for i in 0..<Constants.numberOfMeterViewAssets {
            var s: Double = Double(i) * Constants.maxDialSpeedNormalized / Double(Constants.numberOfMeterViewAssets)
            array_assets.append(createBackground(for_speed: s, with_size: frameSize))
        }
        return array_assets
    }
    
      
    func createBackground(for_speed s: Double, with_size f: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(f, false, 2.0)
        setAxisOrientation()
        drawGradientInCurrentContext(for_speed: s)
        drawProgressCircleInCurrentContext(for_speed: s)
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return backgroundImage
    }
    
    
    // MARK: Indexing pregenerated images
    
     func speedRangeToBackgroundImageRange(start_speed: Double, stop_speed: Double) -> Range<Int> {
        let startIndex = speedToBackgroundImageIndex(start_speed)
        let stopIndex = speedToBackgroundImageIndex(stop_speed)
        return startIndex...stopIndex
    }
    
     func speedToBackgroundImageIndex(s: Double) -> Int {
        let fractionOfDial = speedFractionOfMax(s) // normalize to max speed set
        let backgroundIndex = Int(Double(Constants.numberOfMeterViewAssets) * fractionOfDial)
        return Int(Double(Constants.numberOfMeterViewAssets) * fractionOfDial)
    }
    
     func speedFractionOfMax(s: Double) -> Double {
        let transition_ratio = SpeedGradientConstants.speedAtRedTransition / transitionSpeed
        return s * transition_ratio / Constants.maxDialSpeedNormalized
    }
    
}
