//
//  ContainerViewController.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/10/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case PreferenceExpanded
    case PreferenceCollapsed
}

class ContainerViewController: UIViewController, ViewControllerDelegate {
    
    var mainViewController: ViewController!
    var mainViewNavigationController: UINavigationController!
    var currentState: SlideOutState = SlideOutState.PreferenceCollapsed
    var preferencePaneController : PreferencePaneController?
    
    let preferencePanelExpandedOffset: CGFloat = -60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainViewController = UIStoryboard.mainViewController()
        mainViewController.delegate = self
        
        // wraps main view in a navigation controller
        mainViewNavigationController = UINavigationController(rootViewController: mainViewController)
        view.addSubview(mainViewController.view)
        addChildViewController(mainViewController)
        
        mainViewController.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ViewController delegate method
    func togglePreferencePane() {
        let notAlreadyExpanded = (currentState != SlideOutState.PreferenceExpanded)
        if notAlreadyExpanded {
            addPreferencePaneViewController()
        }
        animatePreferencePane(shouldExpand: notAlreadyExpanded)
    }
    
    // MARK: Container view management method
    func addPreferencePaneViewController() {
        if preferencePaneController == nil {
            preferencePaneController = UIStoryboard.preferencePaneController()
            addChildPreferencePaneController(preferencePaneController!)
        }
    }
    func animatePreferencePane(#shouldExpand: Bool) {
        // # is to have the external parameter name match the variable name
        if (shouldExpand) {
            currentState = .PreferenceExpanded
            animateMainViewYPosition(targetPosition:  preferencePanelExpandedOffset)
        } else {
            animateMainViewYPosition(targetPosition: 0) { finished in
                self.currentState = .PreferenceCollapsed
                self.preferencePaneController!.view.removeFromSuperview()
                self.preferencePaneController = nil
            }
        }
    }
    
    func addChildPreferencePaneController(preferenceController: PreferencePaneController) {
        view.insertSubview(preferenceController.view, atIndex: 0)
        addChildViewController(preferenceController)
        preferenceController.didMoveToParentViewController(self)
    }
    
    func animateMainViewYPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
            options: .CurveEaseInOut,
            animations: {
                self.mainViewController.view.frame.origin.y = targetPosition
            }, completion: completion)
    }
    
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func mainViewController() -> ViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MainViewController") as? ViewController
    }
    
    class func preferencePaneController() -> PreferencePaneController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("PreferencePaneController") as? PreferencePaneController
    }

}