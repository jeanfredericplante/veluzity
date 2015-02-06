//
//  ColorGradient.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/27/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

@IBDesignable class ColorGradient: UIView {
    
    var animationInProgress = false
    var gradientLayer = CAGradientLayer()
    
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
        let frameWidth = UIScreen.mainScreen().bounds.width
        let frameHeight = UIScreen.mainScreen().bounds.height
        let gradientWidth = sqrt(frameWidth*frameWidth+frameHeight*frameHeight)

        gradientLayer.frame = CGRectMake((frameWidth-gradientWidth)/2,
            (frameHeight-gradientWidth)/2, gradientWidth, gradientWidth)
         self.setNeedsDisplay()
    }
    
    private func setColors() {
        let colors: Array = [ startColor.CGColor, stopColor.CGColor ]
        gradientLayer.colors = colors
    }
    
    private func setDirection() {
        CATransaction.setAnimationDuration(3)

        let angle =  CGFloat(gradientDirectionRadians)
        gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
    }
    
    
   
    private func transformCoordinate(x: Double) -> Double {
        return (x+1)/2
    }
    
    private func getMirrorPoint(p: CGPoint) -> CGPoint {
        return CGPoint(x: 1-p.x, y: 1-p.y)
    }
    
    private func setSpeed() {
        if let s = speed {
            if let (sc,ec) = speedToColor(s) {
                CATransaction.setAnimationDuration(3)
                startColor = sc
                stopColor = ec
            }
        }
    }
    

    private func speedToColor(speed: Double) -> (startColor: UIColor, endColor: UIColor)? {
        if speed < 0 {
            return (UIColor.greenColor(), UIColor.whiteColor())
        } else {
            let saturation = CGFloat(0.75)
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
    }
    
    private func speedToHue(speed: Double) -> CGFloat? {
        let speedHueLUT = [(0,120),(30,90),(35,3),(200,0)] //	 speed mph, hue degrees
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
        }
         return nil
    }
    
    
    private func setGradientStartAndEndPoint() {
        gradientLayer.endPoint = CGPoint(x:transformCoordinate(cos(gradientDirectionRadians)),
            y: transformCoordinate(sin(gradientDirectionRadians)))
        gradientLayer.startPoint = getMirrorPoint(gradientLayer.endPoint)
    }
    
}
