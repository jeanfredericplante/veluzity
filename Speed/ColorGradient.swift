//
//  ColorGradient.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/27/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

@IBDesignable class ColorGradient: UIView {
    
    struct Constants {
        static let animDuration = CFTimeInterval(3)
        static let speedAtRedTransition: Double = 28.5
        static let startToEndDeltaSpeed: Double = 3 //gradient end speed - gradient start speed (current speed) m/s

        static let speedHexLUT :[(Double, Int)] =
        [(0, 0x1e2432),
            (3, 0x0b2051),
            (6, 0x022c8e),
            (9, 0x0955aa),
            (11, 0x1875b6),
            (14, 0x2ba8c7),
            (17, 0x2bb9c2),
            (20, 0x01beaa),
            (23, 0x02bc8a),
            (25, 0x04c254),
            (27, 0x03ce0d),
            (28, 0x75c113),
            (29, 0xa9d71b),
            (30, 0xe4c51c),
            (32, 0xe9ad1c),
            (35, 0xe88c15),
            (37, 0xed6912),
            (38, 0xed2d0d),
            (200, 0xf10638)]
    }
    
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
    
    @IBInspectable var speed: Double = 0 {
        didSet { setSpeed() }
    }
    
    @IBInspectable var maxTransitionSpeed: Double = 29 {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
  
    
    var gradientDirectionRadians: Double {
        get {
            // screen is oriented
            return (direction + 90) * M_PI / 180.0
        }
    }
    
    override func drawRect(rect: CGRect) {
        setupView(rect: rect)
    }
    
    // MARK : private methods
    
    private func setupView(rect: CGRect? = nil) {
        setColors()
        if let r = rect {
            gradientLayer.frame = r
        } else
        {
            gradientLayer.frame = UIScreen.mainScreen().bounds
        }
    }
    
    private func setColors() {
        let colors: Array = [ startColor.CGColor, stopColor.CGColor ]
        gradientLayer.colors = colors
    }
    
    private func setDirection() {
        CATransaction.setAnimationDuration(Constants.animDuration)
        if direction >= 0 { setGradientStartAndEndPoint() }
    }
    
    
   
    private func transformCoordinate(x: Double) -> Double {
        // moves into the 0-1 coordinate sys
        return (x+1)/2
    }
    
    private func getMirrorPoint(p: CGPoint) -> CGPoint {
        return CGPoint(x: 1-p.x, y: 1-p.y)
    }
    
    private func setSpeed() {
            if let (sc,ec) = speedToColorGradient(speed) {
                CATransaction.setAnimationDuration(Constants.animDuration)
                startColor = sc; stopColor = ec
            }
    }
    

    private func speedToColorGradient(speed: Double) -> (startColor: UIColor, endColor: UIColor)? {
        
        let sc = speedToColor(speed)
        let ec = speedToColor(speed+Constants.startToEndDeltaSpeed )
        return (sc, ec)
    }
    
    private func speedToColor(s: Double) -> UIColor {
        let normalizedSpeed = normalizeSpeedToMax(s)
        let firstBigger = Constants.speedHexLUT.filter{ (lutspeed,_) in lutspeed >= normalizedSpeed }.first
        let lastSmaller = Constants.speedHexLUT.filter{ (lutspeed,_) in lutspeed <= normalizedSpeed }.last
        let location = (firstBigger, lastSmaller)
        
        switch location {
        case (nil,.Some(let (s2,h2))):
            return SpeedViewsHelper.hexToUIColor(h2)
        case (.Some(let (s1,h1)), nil):
            return SpeedViewsHelper.hexToUIColor(h1)
        case (.Some(let (s1,h1)), .Some(let (s2,h2))):
            let rgb1 = SpeedViewsHelper.hexToRGB(h1)
            let rgb2 = SpeedViewsHelper.hexToRGB(h2)
            let ri = interp1(x0: s1, x1: s2, y0: rgb1.r, y1: rgb2.r, x: normalizedSpeed)
            let gi = interp1(x0: s1, x1: s2, y0: rgb1.g, y1: rgb2.g, x: normalizedSpeed)
            let bi = interp1(x0: s1, x1: s2, y0: rgb1.b, y1: rgb2.b, x: normalizedSpeed)
            return UIColor(red: ri, green: gi, blue: bi, alpha: 1)
        default:
            return UIColor.blackColor()
  
        }
    }
    
    private func normalizeSpeedToMax(speed: Double) -> Double {
        if self.maxTransitionSpeed == 0 {
            return 0
        } else {
            return max(0.0, speed*Constants.speedAtRedTransition/self.maxTransitionSpeed)
        }
    }
    
    private func interp1(#x0: Double, x1: Double, y0: CGFloat, y1: CGFloat, x: Double) -> CGFloat {
        let slider = CGFloat(Double(x-x0) / Double(x1-x0)) // need to split into as got weird archive error
        let boundedSlider = min(1.0, max(0.0, slider))
        return y0 + (y1 - y0)*boundedSlider
    }
    
    private func setGradientStartAndEndPoint() {
        gradientLayer.startPoint = CGPoint(x:transformCoordinate(cos(gradientDirectionRadians)),
            y: transformCoordinate(sin(gradientDirectionRadians)))
        gradientLayer.endPoint = getMirrorPoint(gradientLayer.startPoint)
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
