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
        enum Style {
            case Round
            case Square
            case RoundNoBackground
        }
        static let numberOfMeterViewAssets = 180
        static let currentStyle = Style.RoundNoBackground
        static let maxDuration: TimeInterval = 0.75
        static let meterRadius: CGFloat = 75
        static let meterWidth: CGFloat = 15
        static let gradientClipWidth: CGFloat = 140
        static let startAngleOffset: Double = Double.pi/6
        static let maxDialSpeedNormalized: Double = SpeedGradientConstants.speedAtRedTransition / Params.SpeedMeter.maxSpeedFractionOfDial // "normalized" to transition at red, needs refactor to be normalized to 0-1
        static let timeHeaderHeight: CGFloat = 20
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
        viewBounds = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - Constants.timeHeaderHeight)
        print("init meter with view bounds size width \(viewBounds.width) and height \(viewBounds.height)")

    }
    
    
    // MARK: Creation of the pregenerated background and progress meter images
    var animationDuration: TimeInterval {
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
            let ctx = UIGraphicsGetCurrentContext()!
            let colors: CFArray = [sc.cgColor,ec.cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: colorspace, colors: colors, locations: [0,1])!
            let startPoint = CGPoint(x: 0, y: 0)
            let endPoint = CGPoint(x: 0, y: viewBounds.height)
            switch Constants.currentStyle {
            case .Round:
                let xMin = viewBounds.midX - Constants.gradientClipWidth/2
                let yMin = viewBounds.midY - Constants.gradientClipWidth/2
                ctx.addEllipse(in: CGRect(x: xMin, y: yMin, width: Constants.gradientClipWidth, height: Constants.gradientClipWidth))
            case .Square:
                ctx.addRect(viewBounds)
            default:
                break
            }
            ctx.clip()
            ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        }
    }
    
    
    func drawProgressCircleInCurrentContext(for_speed s: Double) {
        // Setup for dial with gradient background: radius 60, width 5
        // draws background
        addArcPathInCurrentContext(speed_percentage: 1.0, with_stroke_color: UIColor.white, and_opacity: 0.1)
        
        // draws speed
        let speedPercentage = speedFractionOfMax(s: s)
        switch Constants.currentStyle {
        case .Square, .Round:
            addArcPathInCurrentContext(speed_percentage: speedPercentage, with_stroke_color: UIColor.white, and_opacity: 1.0)
        case .RoundNoBackground:
            let dial_color = speedToColor(s: s, maxTransitionSpeed: transitionSpeed)
            addArcPathInCurrentContext(speed_percentage: speedPercentage, with_stroke_color: dial_color, and_opacity: 1.0)
        }

    }
    
    func addArcPathInCurrentContext(speed_percentage: Double, with_stroke_color dial_color: UIColor, and_opacity dial_opacity: CGFloat) {
        let path = CGMutablePath()
        let c = UIGraphicsGetCurrentContext()!
        
        let outerRadius = Constants.meterRadius - Constants.meterWidth/2
        let center = CGPoint(x: viewBounds.midX, y: viewBounds.midY)
        let startAngle =  CGFloat((3*Double.pi/2) - Constants.startAngleOffset)
        let endAngle = startAngle - CGFloat((2*Double.pi - 2*Constants.startAngleOffset) * speed_percentage)
        
        // Creates path
        path.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        // Create stroke
        let backgroundColor = dial_color.withAlphaComponent(dial_opacity)
        backgroundColor.set()
        c.addPath(path)
        c.setLineWidth(Constants.meterWidth)
        c.setLineCap(.round)
        c.strokePath()

    }
    
    func drawSpeedTextInCurrentContext(for_speed s: Double) {
        guard let c = UIGraphicsGetCurrentContext() else {
            return
        }
        let speed = String(format: "%.0f",localizeSpeed(speed: s, isMph: true) ?? 0)
        let font = UIFont.systemFont(ofSize: 50)
        let x = viewBounds.midX
        let y = viewBounds.midY
        let attr = [NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        let attributedString = NSAttributedString(string: speed, attributes: attr)
        let line = CTLineCreateWithAttributedString(attributedString)

        c.textPosition = CGPoint(x: x-attributedString.size().width/2, y: y-attributedString.size().height/4)
        CTLineDraw(line, c)
     }
    
    func setAxisOrientation() {
        let c = UIGraphicsGetCurrentContext()!
        c.translateBy(x: 0.0, y: viewBounds.height)
        c.scaleBy(x: 1.0, y: -1.0)
    }
    
    func createAssetsForCaching() -> [UIImage] {
        var array_assets: [UIImage] = []
        let transition_ratio = SpeedGradientConstants.speedAtRedTransition / transitionSpeed

        for i in 0..<Constants.numberOfMeterViewAssets {
            let s: Double = Constants.maxDialSpeedNormalized * Double(i) / Double(Constants.numberOfMeterViewAssets) / transition_ratio
            array_assets.append(createBackground(for_speed: s, with_size: frameSize))
        }
        return array_assets
    }
    
      
    func createBackground(for_speed s: Double, with_size f: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(f, false, 2.0)
        setAxisOrientation()
        switch Constants.currentStyle {
        case .Round, .Square:
            drawGradientInCurrentContext(for_speed: s)
        default:
            break
        }
        drawProgressCircleInCurrentContext(for_speed: s)
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return backgroundImage
    }
    
    
    // MARK: Indexing pregenerated images
    
     func speedRangeToBackgroundImageRange(start_speed: Double, stop_speed: Double) -> Range<Int> {
        let startIndex = speedToBackgroundImageIndex(s: start_speed)
        let stopIndex = speedToBackgroundImageIndex(s: stop_speed)

        if startIndex <= startIndex {
            return 	startIndex..<stopIndex
        } else {
            return stopIndex..<startIndex
        }
    }
    
     func speedToBackgroundImageIndex(s: Double) -> Int {
        let fractionOfDial = speedFractionOfMax(s: s) // normalize to max speed set
        let backgroundIndex = Int(Double(Constants.numberOfMeterViewAssets) * fractionOfDial)
        return max(0, min(Constants.numberOfMeterViewAssets-1, backgroundIndex))
    }
    
     func speedFractionOfMax(s: Double) -> Double {
        let transition_ratio = SpeedGradientConstants.speedAtRedTransition / transitionSpeed
        return s * transition_ratio / Constants.maxDialSpeedNormalized
    }
    
}
