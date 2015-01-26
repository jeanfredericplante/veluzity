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
    enum viewColors {
        case Speed, Location, Heading, Weather
        func toHex() -> Int {
            switch self {
            case Weather:
                return 0xCCFF66
            case Location:
                return 0x12FFF7
            case Heading:
                return 0x7EFFBB
            default:
                return 0xFFFFFF
            }
        }
    }
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
            degreesText = NSString(format: "%.0f° ", degrees!) }
        
        if cardinality != nil {
            cardinalDirection = cardinality
        }
        return textWithTwoFontSizes(degreesText, smallText: cardinalDirection, font: font, ratio: Constants.fontRatio)
    }
    
    
    class func weatherViewFormattedText(temperature: Double!, description: String! = nil, font: UIFont) -> NSAttributedString {
        var temperatureText: String = ""
        var descriptionText: String = ""
        
        if temperature != nil { temperatureText = NSString(format: "%.0f° ", temperature!) }
        if description != nil { descriptionText = description }
        
        return textWithTwoFontSizes(temperatureText, smallText: description, font: font, ratio: 0.4)
    }
    
    
    
    class func getWeatherColor() -> UIColor {
        return hexToUIColor(Constants.viewColors.Weather.toHex())
    }
    
    class func getHeadingColor() -> UIColor {
        return hexToUIColor(Constants.viewColors.Heading.toHex())
    }
    
    class func getLocationColor() -> UIColor {
        return hexToUIColor(Constants.viewColors.Location.toHex())
    }
    
    
    class func hexToUIColor(hexValue: Int) -> UIColor {
        var red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
        var green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
        var blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}


