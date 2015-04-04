//
//  SlideOutController.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 4/3/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation

class SlideOutController: UITableViewController {
    
    // MARK: transition methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let parentVC = self.parentViewController {
            if let parentVC = parentVC as? ContainerViewController {
                parentVC.closePreferencePane()
            }
        }
    }
    
}
