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
    static let addShadowsToFont = false
    static let hasGradientBackground = true
    enum ViewColors {
        case Speed, Location, Heading, Weather
        func toHex() -> Int {
            if hasGradientBackground {
                return 0xFFFFFF // white foreground objects when there is a gradient
            } else {
                switch self {
                case Weather:
                    return 0xCCFF66
                case Location:
                    return 0x12FFF7
                case Heading:
                    return 0x7EFFBB
                case Speed:
                    return 0x40FFF8
                default:
                    return 0xFFFFFF
                }
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
            let allSubviews = view.subviews
            let allLabels = allSubviews.filter({$0.isKindOfClass(UILabel)}) as [UILabel]
            for textLabel in allLabels {
                textLabel.textColor = color
                if Constants.addShadowsToFont {
                    textLabel.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                    textLabel.shadowOffset = CGSize(width: 0,height: 1)
                }
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
        if degrees != nil && degrees >= 0  && cardinality != nil
        {
            degreesText = NSString(format: "%.0f° ", degrees!)
            cardinalDirection = cardinality
            return textWithTwoFontSizes(degreesText, smallText: cardinalDirection, font: font, ratio: Constants.fontRatio)

        } else {
            return textWithTwoFontSizes("0°", smallText: "N", font: font, ratio: Constants.fontRatio)
        }
        
    }
    
    
    
    class func cityAndStateText(city: String?, state: String?) -> String {
        if let stateName = state {
            if let cityName = city {
                return cityName + ", " + stateName
            }
        }
        return ""
    }
    
    
    class func weatherViewFormattedText(temperature: Double?, description: String! = nil, font: UIFont) -> NSAttributedString {
        var descriptionText: String = ""
 
        if description != nil { descriptionText = "" + description }
        
        // adding a space for line break with small labels
        return textWithTwoFontSizes(formattedTemperature(temperature), smallText: descriptionText, font: font, ratio: 0.4)
    }
    
    
    class func formattedTemperature(temperature: Double?) -> NSString {
        var formattedTemp: NSString
        if let temp = temperature {
            formattedTemp = NSString(format: "%.0f°", temp)
        } else {
            formattedTemp = NSString(string: "--°")
        }
        return formattedTemp
    }
    
    class func getWeatherIconImage() -> UIImage? {
        return nil
    }
    
    class func isLandscape() -> Bool {
        return UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)
    }

    
    // TODO: how to get rid of all that repetition
    
    class func getWeatherColor() -> UIColor {
        return hexToUIColor(Constants.ViewColors.Weather.toHex())
    }
    
    class func getHeadingColor() -> UIColor {
        return hexToUIColor(Constants.ViewColors.Heading.toHex())
    }
    
    class func getLocationColor() -> UIColor {
        return hexToUIColor(Constants.ViewColors.Location.toHex())
    }
    
    class func getColorForElement(e: Constants.ViewColors) -> UIColor {
        return hexToUIColor(e.toHex())
    }
    
    
    class func hexToUIColor(hexValue: Int) -> UIColor {
        let (red,green,blue) = hexToRGB(hexValue)
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    class func hexToRGB(hexValue: Int) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        var red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
        var green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
        var blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
        return (red, green, blue)
    }
    
    class func RGBtoHSV(#r: CGFloat, g:CGFloat, b: CGFloat) -> (h: CGFloat, s: CGFloat, v:CGFloat)? {
        let c = UIColor(red: r,green: g,blue: b,alpha: 1)
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        if c.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return (hue, saturation, brightness)
        } else {
            return nil
        }
    }
    
    class func hexToHSV(hexValue: Int) -> (h: CGFloat, s: CGFloat, v:CGFloat)? {
        let rgb = hexToRGB(hexValue)
        if let hsv = RGBtoHSV(r: rgb.r, g: rgb.g, b: rgb.b) {
            return (hsv.h, hsv.s, hsv.v)
        } else {
            return nil
        }
        
    }
    
 
}


