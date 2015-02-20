//
//  ColorGradient.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/27/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

@IBDesignable class ColorGradient: UIView {
    
    let AnimDuration = CFTimeInterval(3)
    var animationInProgress = false
    var gradientLayer = CAGradientLayer()
    let speedHexLUT :[(Double, Int)] = [(0, 0x1e2432),
    (3, 0x0b2051),
    (6, 0x022c8e),
    (9, 0x0955aa),
    (11, 0x1875b6),
    (14, 0x2ba8c7),
    (17, 0x32d8de),
    (20, 0x1bead4),
    (23, 0x13ebb1),
    (25, 0x0eee6d),
    (27, 0x09df13),
    (28, 0x75c113),
    (29, 0xa9d71b),
    (30, 0xe4c51c),
    (32, 0xe9ad1c),
    (35, 0xe88c15),
    (37, 0xed6912),
    (38, 0xed2d0d),
    (200, 0xf10638)]

  
    @IBInspectable var startColor: UIColor = UIColor.blackColor() {
        didSet { setColors() }
    }
    
    @IBInspectable var stopColor: UIColor = UIColor.grayColor() {
        didSet { setColors() }
    }
    
    @IBInspectable var direction: Double = 0 {
        didSet { setDirection() }
    }
    
    @IBInspectable var speed: Double? {
        didSet { setSpeed() }
    }
    
    
    // MARK: override methods
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()

        self.layer.insertSublayer(gradientLayer, atIndex: 0)
        
    }
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }

    
    var gradientDirectionRadians: Double {
        get {
            // screen is oriented
            return (direction + 90) * M_PI / 180.0
        }
    }
    
    // MARK : private methods
    
    private func setupView() {
        setColors()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        // not sure why self.frame not initialized properly. Uses mainScreen bounds instead
        self.setNeedsDisplay()
    }
    
    private func setColors() {
        let colors: Array = [ startColor.CGColor, stopColor.CGColor ]
        gradientLayer.colors = colors
    }
    
    private func setDirection() {
        CATransaction.setAnimationDuration(AnimDuration)
        setGradientStartAndEndPoint()
    }
    
    
   
    private func transformCoordinate(x: Double) -> Double {
        // moves into the 0-1 coordinate sys
        return (x+1)/2
    }
    
    private func getMirrorPoint(p: CGPoint) -> CGPoint {
        return CGPoint(x: 1-p.x, y: 1-p.y)
    }
    
    private func setSpeed() {
        if let s = speed {
            if let (sc,ec) = speedToColor(s) {
                CATransaction.setAnimationDuration(AnimDuration)
                startColor = sc; stopColor = ec
            }
        }
    }
    

    private func speedToColor(speed: Double) -> (startColor: UIColor, endColor: UIColor)? {
        
        let saturation = CGFloat(1)
        let endBrightness = CGFloat(0.35)
        let startBrightness = CGFloat(0.60)
        if let hue = speedToHue(speed) {
            println("speed is \(speed) 75hue is \(hue)")
            let sc = UIColor(hue: hue, saturation: saturation, brightness: startBrightness, alpha: 1)
            let ec = UIColor(hue: hue, saturation: saturation, brightness: endBrightness, alpha: 1)
            return (sc, ec)
        } else {
            return nil
        }
        
    }
    
    // TODO: need to obsolete
    private func speedToHue(speed: Double) -> CGFloat? {
        let speedHueLUT = [(0,120),(30,90),(35,3),(200,0)] //	 speed mps, hue degrees
        func degreesToHue(deg: Int) -> CGFloat {
            let resAngle = Double(deg%361)
            return CGFloat(resAngle/360.0)
        }
        let firstBigger = speedHueLUT.filter{ (lutspeed,_) in lutspeed >= Int(speed) }.first
        let lastSmaller = speedHueLUT.filter{ (lutspeed,_) in lutspeed <= Int(speed) }.last
        if let (s1, h1) = lastSmaller {
            if let (s2, h2) = firstBigger {
                if s2 > s1 {
                    let slope = Double(h2 - h1) / Double(s2 - s1)
                    let hueInterp = Double(h1) + slope * Double(Int(speed) - s1)
                    return degreesToHue(Int(hueInterp))
                } else {
                    return degreesToHue(h1)
                }
            }
            return degreesToHue(h1)
        } else if let (s2, h2) = firstBigger {
            return degreesToHue(h2)
        }
        return nil
    }
    
    
    private func speedToColor(speed: Double) -> UIColor {
        let firstBigger = speedHexLUT.filter{ (lutspeed,_) in lutspeed >= speed }.first
        let lastSmaller = speedHexLUT.filter{ (lutspeed,_) in lutspeed <= speed }.last
        let location = (firstBigger, lastSmaller)
        
        switch location {
        case (nil,.Some(let (s2,h2))):
            return SpeedViewsHelper.hexToUIColor(h2)
        case (.Some(let (s1,h1)), nil):
            return SpeedViewsHelper.hexToUIColor(h1)
        case (.Some(let (s1,h1)), .Some(let (s2,h2))):
            let rgb1 = SpeedViewsHelper.hexToRGB(h1)
            let rgb2 = SpeedViewsHelper.hexToRGB(h2)
            let ri = interp1(x0: s1, x1: s2, y0: rgb1.r, y1: rgb2.r, x: speed)
            let gi = interp1(x0: s1, x1: s2, y0: rgb1.g, y1: rgb2.g, x: speed)
            let bi = interp1(x0: s1, x1: s2, y0: rgb1.b, y1: rgb2.b, x: speed)
            return UIColor(red: ri, green: gi, blue: bi, alpha: 1)
        default:
            return UIColor.blackColor()
  
        }
    }
    
    private func interp1(#x0: Double, x1: Double, y0: CGFloat, y1: CGFloat, x: Double) -> CGFloat {
        let slider = CGFloat(max(min(Double(x-x0) / Double(x1-x0),1), 0))
        return y0 + (y1 - y0)*slider
    }
    
    private func setGradientStartAndEndPoint() {
        gradientLayer.endPoint = CGPoint(x:transformCoordinate(cos(gradientDirectionRadians)),
            y: transformCoordinate(sin(gradientDirectionRadians)))
        gradientLayer.startPoint = getMirrorPoint(gradientLayer.endPoint)
    }
    
    private func rotateGradientOfDirection() {
        
        
        let angle =  CGFloat(gradientDirectionRadians)
        let frameWidth = UIScreen.mainScreen().bounds.width
        let frameHeight = UIScreen.mainScreen().bounds.height
        let gradientWidth = sqrt(frameWidth*frameWidth+frameHeight*frameHeight)

        gradientLayer.frame = CGRectMake((frameWidth-gradientWidth)/2,
            (frameHeight-gradientWidth)/2, gradientWidth, gradientWidth)
        gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
 
    }
    
   
    
    
}
