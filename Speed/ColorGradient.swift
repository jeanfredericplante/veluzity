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
        didSet { setupView() }
    }
    
    @IBInspectable var stopColor: UIColor = UIColor.grayColor() {
        didSet { setupView() }
    }
    
    @IBInspectable var direction: Double = 0 {
        didSet { setDirection() }
    }
    
    @IBInspectable var speed: Double? {
        didSet { setColors() }
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
    
    
    var gradientDirectionRadians: Double {
        get {
            // screen is oriented
            return (direction + 90) * M_PI / 180.0
        }
    }
    
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
        if speed == nil {
            let colors: Array = [ startColor.CGColor, stopColor.CGColor ]
            gradientLayer.colors = colors
        } else {
            
        }
        
    }
    
    private func setDirection() {
        let angle =  CGFloat(gradientDirectionRadians)
        gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
    }
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
    
   
    private func transformCoordinate(x: Double) -> Double {
        return (x+1)/2
    }
    
    private func getMirrorPoint(p: CGPoint) -> CGPoint {
        return CGPoint(x: 1-p.x, y: 1-p.y)
    }
    
    private func speedToColor(speed: Double) -> (startColor: UIColor, endColor: UIColor) {
        if speed < 0 {
            return (UIColor.greenColor(), UIColor.whiteColor())
        } else {
            var endBrightness = 35/100
	
            return (UIColor.greenColor(), UIColor.whiteColor())
        }
    }
    private func speedToHue(speed: Double) -> CGFloat? {
        let speedHueLUT = [(0,120),(70,90),(90,0)] // speed mph, hue degrees
        let firstBigger = speedHueLUT.filter{ (lutspeed,_) in lutspeed >= Int(speed) }.first
        let lastSmaller = speedHueLUT.filter{ (lutspeed,_) in lutspeed <= Int(speed) }.last
        if let (speed1, hue1) = firstBigger {
            if let (speed2, hue2) = lastSmaller {
                
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
