//
//  InfoViewWithIcon.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/24/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

class InfoViewWithIcon: ViewWithText {
    
    
    override init(view: UIView! = nil, textColor: UIColor = .whiteColor()) {
        super.init(view: view, textColor: textColor)
        setImageViewsTintColor(textColor)
    }
    
    
    func setImageViewsTintColor(color: UIColor!) {
        if color != nil {
            let allImageViews = currentView!.subviews.filter({$0.isKindOfClass(UIImageView)}) as [UIImageView]
            for imageView in allImageViews {
                    imageView.image = imageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    imageView.tintColor = color

            }
        }
    }
}


