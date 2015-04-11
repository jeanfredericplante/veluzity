//
//  ColorGradient.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/27/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit
import VeluzityKit

@IBDesignable class ColorGradient: UIView {
    
    struct Constants {
        static let animDuration = CFTimeInterval(3)
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
        if let (sc,ec) = speedToColorGradient(speed: speed, maxTransitionSpeed: maxTransitionSpeed) {
            CATransaction.setAnimationDuration(Constants.animDuration)
            startColor = sc; stopColor = ec
        }
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
