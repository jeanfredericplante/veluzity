//
//  ViewWithText.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/24/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

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
}


