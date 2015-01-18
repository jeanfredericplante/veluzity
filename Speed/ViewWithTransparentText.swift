//
//  viewWithTransparentText.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/11/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

class ViewWithTransparentText {
    var currentView: UIView?
    var backgroundColor: UIColor = .whiteColor()
    var foregroundColor: UIColor = .blackColor()
    
    init(view: UIView! = nil, textColor: UIColor = .whiteColor()) {
        currentView = view
        self.backgroundColor = textColor
        foregroundColor = currentView!.backgroundColor!
        addSubviewWithColor(backgroundColor)
        addTextLayer()
        setTextBlendMode()
    }
    
    func addSubviewWithColor(color: UIColor) {
        currentView!.alpha = 0.99
        currentView!.backgroundColor = color
        var colorLayer = CAGradientLayer()
//        //UIView(frame: CGRect(origin: CGPoint(x: 0,y: 0), size: currentView!.frame.size))
//        colorLayer.backgroundColor = UIColor.blackColor()
//        colorLayer.alpha = 0.5
//        currentView!.insertSubview(colorLayer, atIndex: 0)
//        
//
    }
    
    func addTextLayer() {
//        var textLayer = CATextLayer()
//        textLayer.foregroundColor = CGC CGColor.clearColor()
//        textLayer.string = "Test"
//        currentView!.addSubview(textLayer)
    }
    
    func setTextBlendMode() {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetBlendMode(context, kCGBlendModeCopy)
        let allLabels = currentView!.subviews.filter({$0.isKindOfClass(UILabel)}) as [UILabel]
        for textLabel in allLabels {
            textLabel.textColor = UIColor.clearColor()
            textLabel.drawTextInRect(currentView!.frame)
       }
    }
    
    
}
