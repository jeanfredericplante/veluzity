//
//  MeterView.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 4/5/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation
import WatchKit

class MeterView {
    struct Constants {
        static let maxDuration: NSTimeInterval = 0.75
    }
    
    var frameSize: CGSize = CGSizeMake(0,0)
    
    init(meterSize: CGSize) {
        frameSize = meterSize
    }
    
    
    /// The length that the Glance badge image will animate.
    var animationDuration: NSTimeInterval {
        return Constants.maxDuration
    }

    var meterBackgroundImage: UIImage {
        UIGraphicsBeginImageContextWithOptions(frameSize, false, 2.0)
        drawGradientAndSpeedInCurrentContext()
        let frame = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return frame
    }
    
    func drawGradientAndSpeedInCurrentContext() {
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let gColorsRGBA: [CGFloat] = [
            0, 0, 0, 1,
            0, 0, 1, 1
        ]
        let gradient = CGGradientCreateWithColorComponents(colorspace, gColorsRGBA, [0,1], 2)
        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: 0, y: frameSize.height)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, startPoint, endPoint, 0)
        
    }
    
}
