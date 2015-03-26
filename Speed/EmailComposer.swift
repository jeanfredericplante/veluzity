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
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["veluzity@gmail.com"])
        mailComposerVC.setSubject("Feedback for Veluzity")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
