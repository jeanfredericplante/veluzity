//
//  SlideOutController.swift
//  Veluzity
//
//  Created by Jean Frederic Plante on 4/3/15.
//  Copyright (c) 2015 Fantastic Whale Labs. All rights reserved.
//

import Foundation

class SlideOutController: UITableViewController, UITableViewDelegate {
    
    let emailView = EmailComposer()
    @IBOutlet weak var contactUsLabel: UILabel!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // check whether email is available
    }
    
    // MARK: transition methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let parentVC = self.parentViewController {
            if let parentVC = parentVC as? ContainerViewController {
                parentVC.closePreferencePane()
            }
        }
    }
    
    
    private func presentFeedbackEmail() {
        let configuredMailComposeViewController = emailView.configuredMailComposeViewController()
        if emailView.canSendMail()
        {
            presentViewController(configuredMailComposeViewController, animated: true, completion: nil)
        }

    }
    
    // MARK: table view delegate methods
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 1) {
            if emailView.canSendMail() {
                println("row 1 pressed")
            } else {
                cantSendEmailAlert()
            }
        }
    }
    
    
    
    private func cantSendEmailAlert() -> Void {
        let noemailController = UIAlertController(title: "Oh noooos!", message: "Veluzity can't send an email on your behalf, but here's our email address for feedback: veluzity@gmail.com", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        noemailController.addAction(defaultAction)

        presentViewController(noemailController, animated: true, completion: nil)

    }
    
}
