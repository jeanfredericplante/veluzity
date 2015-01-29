//
//  ColorGradient.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/27/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

@IBDesignable class ColorGradient: UIView {
    
    var gradientLayer = CAGradientLayer()
    
    @IBInspectable var startColor: UIColor = UIColor.blackColor() {
        didSet { setupView() }
    }
    
    @IBInspectable var stopColor: UIColor = UIColor.grayColor() {
        didSet { setupView() }
    }
    
    @IBInspectable var direction: Double = 0 {
        didSet { setupView() }
    }
    
    
    // MARK: override methods
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
        setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
        setupView()

    }
    
    
    
    

    var gradientDirectionRadians: Double {
        get {
            return direction * M_PI / 180.0
        }
    }
    
    private func setupView() {
        let colors: Array = [ startColor.CGColor, stopColor.CGColor ]

        gradientLayer.endPoint = CGPoint(x:transformCoordinate(cos(gradientDirectionRadians)),
            y: transformCoordinate(sin(gradientDirectionRadians)))
        gradientLayer.startPoint = getMirrorPoint(gradientLayer.endPoint)
        gradientLayer.colors = colors
        gradientLayer.frame = self.bounds
        
        self.setNeedsDisplay()

    }

    private func transformCoordinate(x: Double) -> Double {
        return (x+1)/2
    }
    
    private func getMirrorPoint(p: CGPoint) -> CGPoint {
        return CGPoint(x: 1-p.x, y: 1-p.y)
    }

}
