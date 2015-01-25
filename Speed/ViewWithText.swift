//
//  ViewWithText.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/24/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

class ViewWithText {

        var currentView: UIView!
        var textColor: UIColor!
        
        init(view: UIView! = nil, textColor: UIColor = .whiteColor()) {
            self.currentView = view
            self.textColor = textColor
            setLabelsColor(color: textColor)
        }
        
    func setLabelsColor(color: UIColor! = UIColor.whiteColor()) {
            let allLabels = currentView!.subviews.filter({$0.isKindOfClass(UILabel)}) as [UILabel]
            for textLabel in allLabels {
                textLabel.textColor = color
            }
        }
    
}
