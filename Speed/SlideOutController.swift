//
//  SlideOutController.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 4/3/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation

@objc // makes protocol available from Objective C
protocol SlideOutDelegate {
    optional func aboutUsTapped()
    optional func settingsTapped()
}

class SlideOutController: UITableViewController {
    //removed ui table view delegate
    
    let emailView = EmailComposer()
    var delegate: SlideOutDelegate?
    
 
    
    // MARK: transition methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        closeSlideOutPanel()
    }
    
    
    private func presentFeedbackEmail() {
        Flurry.logEvent("feedback_email_load")
        let configuredMailComposeViewController = emailView.configuredMailComposeViewController()
        if emailView.canSendMail()
        {
            presentViewController(configuredMailComposeViewController, animated: true, completion: nil)
        }

    }
    
    // MARK: table view delegate methods
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.row {
        case 0:
            delegate?.settingsTapped?()
        case 1:
            
                if emailView.canSendMail() {
                    print("row 1 pressed")
                    presentFeedbackEmail()
                } else {
                    cantSendEmailAlert()
                }
        case 2:
            delegate?.aboutUsTapped?()
        default:
            break
        }
        
    }
    
    override  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // customize selected color for table view
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(red: 0.1668, green: 0.1706, blue: 0.2186, alpha: 1)
        cell.selectedBackgroundView = selectedView
    }
    
    
    private func cantSendEmailAlert() -> Void {
        let noemailController = UIAlertController(title: "Oh noooos!", message: "Veluzity can't send an email on your behalf, but here's our email address for feedback: veluzity@gmail.com", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        noemailController.addAction(defaultAction)

        presentViewController(noemailController, animated: true, completion: nil)

    }
    
    private func closeSlideOutPanel() {
        if let parentVC = self.parentViewController {
            if let parentVC = parentVC as? ContainerViewController {
                parentVC.closeSlideOut()
            }
        }

    }

}
