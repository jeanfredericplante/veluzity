//
//  EmailComposer.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 3/25/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation
import MessageUI
import UIKit


class EmailComposer: MFMailComposeViewController, MFMailComposeViewControllerDelegate {
    
    func canSendMail() -> Bool
    {
        return MFMailComposeViewController.canSendMail()
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController
    {
        let mailComposerVC = MFMailComposeViewController()
        let body = gatherDeviceInformationForFeedback()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["veluzity+support@gmail.com"])
        mailComposerVC.setSubject("Feedback for Veluzity")
        mailComposerVC.setMessageBody(body, isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    private func gatherDeviceInformationForFeedback() -> String {
        // let spaceBefore = Array(count: 3, repeatedValue: "") // Unused variable
        let deviceModel = "Model: \(UIApplicationUtils.getDeviceModel())"
        let osVersion = "OS Version: \(UIApplicationUtils.getOSVersion())"
        let screenSize = UIApplicationUtils.getScreenSize()
        let appVersion = "App Version: \(UIApplicationUtils.getAppVersion()) (\(UIApplicationUtils.getAppBuild()))"
        
        return ["", "", "", appVersion, deviceModel, osVersion, screenSize].joined(separator: "\n")
    }
    
    
}
