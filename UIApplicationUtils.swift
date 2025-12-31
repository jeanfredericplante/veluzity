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
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? ""
    }
    
    class func getAppVersion() -> String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "-"
    }
    
    class func getAppBuild() -> String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "-"
    }
    
    class func getDeviceModel() -> String {
        return UIDevice.current.model
    }
    
    class func getOSVersion() -> String {
        return (UIDevice.current.systemVersion)
    }
    
    class func getScreenSize() -> String {
        let screenSize: CGRect = UIScreen.main.bounds
        return "Screen size: \(screenSize.width)x\(screenSize.height)"
    }

}
