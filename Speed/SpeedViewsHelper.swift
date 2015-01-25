//
//  ViewWithText.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/24/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit
struct Constants {
    static let fontRatio: CGFloat = 0.5
}
class SpeedViewsHelper {
   
    
    
    class func setImageAndTextColor(view: UIView! = nil, color: UIColor! = UIColor.whiteColor()) {
        if view != nil {
            SpeedViewsHelper.setImageViewsTintColor(view: view, color: color)
            SpeedViewsHelper.setLabelsColor(view: view, color: color)
        }
    }
    
    
    class func setLabelsColor(view: UIView! = nil, color: UIColor! = UIColor.whiteColor()) {
        if view != nil {
            let allLabels = view.subviews.filter({$0.isKindOfClass(UILabel)}) as [UILabel]
            for textLabel in allLabels {
                textLabel.textColor = color
            }
        }
    }
    
    class func setImageViewsTintColor(view: UIView! = nil, color: UIColor! = UIColor.whiteColor()) {
        if view != nil {
            let allImageViews = view.subviews.filter({$0.isKindOfClass(UIImageView)}) as [UIImageView]
            for imageView in allImageViews {
                imageView.image = imageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                imageView.tintColor = color
                
            }
        }
    }
    
    class func textWithTwoFontSizes(bigText: String, smallText: String,
        font: UIFont, ratio: CGFloat) -> NSAttributedString {
            var smallFontSize: CGFloat = round(font.pointSize * ratio)
            var smallFont = font.fontWithSize(smallFontSize)
            var bigAttrText = NSMutableAttributedString(string: bigText, attributes: [NSFontAttributeName: font])
            var smallAttrText = NSMutableAttributedString(string: smallText, attributes: [NSFontAttributeName: smallFont])
            bigAttrText.appendAttributedString(smallAttrText)
            return bigAttrText
    }
    
    
    // MARK: views specific function
    class func headingViewFormattedText(degrees: Double!, cardinality: String!, font: UIFont) -> NSAttributedString {
        var degreesText: String = ""
        var cardinalDirection: String = ""
        if degrees != nil && degrees >= 0  {
            degreesText = NSString(format: "%.0f°", degrees!) }
        
        if cardinality != nil {
            cardinalDirection = cardinality
        }
        return textWithTwoFontSizes(degreesText, smallText: cardinalDirection, font: font, ratio: Constants.fontRatio)
    }
}


