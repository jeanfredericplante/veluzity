//
//  UIApplicationUtils.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 3/26/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import UIKit

class UIApplicationUtils: NSObject {
    
    
    class func getAppName() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as String
    }
    
    class func getAppVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String
    }
    
    class func getAppBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as String
    }
    
    class func getDeviceModel() -> String {
        return UIDevice.currentDevice().model
    }
    
    class func getOSVersion() -> String {
        return (UIDevice.currentDevice().systemVersion)
    }
    
    class func getScreenSize() -> String {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        return "Screen size: \(screenSize.width)x\(screenSize.height)"
    }

}


