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

class ContainerViewController: UIViewController, ViewControllerDelegate, UIGestureRecognizerDelegate {
    
    struct Constants {
        static let preferencePanelExpandedOffset: CGFloat = 270
    }

    var mainViewController: DashboardViewController!
    var mainViewNavigationController: UINavigationController!
    var currentState: SlideOutState = SlideOutState.PreferenceCollapsed {
        didSet {
            let shouldShowShadow = currentState != .PreferenceCollapsed
            showShadowForMainView(shouldShowShadow)
        }
    }
    var slideOutController : SlideOutController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainViewController = UIStoryboard.mainViewController()
        mainViewController.view.layer.shadowOffset = CGSize(width: 0,height: 3)

        mainViewController.delegate = self
        
        // Sets up view controller for the dashboard, and hierarchy
        mainViewNavigationController = UINavigationController(rootViewController: mainViewController)
        self.view.addSubview(mainViewController.view)
        addChildViewController(mainViewController)
        mainViewController.didMoveToParentViewController(self)
        
        // adds tap gesture detection
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        mainViewController.view.addGestureRecognizer(panGestureRecognizer)
        println(" supported orientations \(self.supportedInterfaceOrientations())")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        closePreferencePane()
    }
    
    
    
    
    
    // MARK: ViewController delegate method
    func togglePreferencePane() {
        let notAlreadyExpanded = (currentState != SlideOutState.PreferenceExpanded)
        let shouldI = notAlreadyExpanded
        if notAlreadyExpanded {
            addPreferencePaneViewController()
        }
        animatePreferencePane(shouldExpand: shouldI)
    }
    
    func expandedOffset() -> CGFloat {
        return Constants.preferencePanelExpandedOffset
    }
    
    func closePreferencePane() {
        if currentState == SlideOutState.PreferenceExpanded {
            animatePreferencePane(shouldExpand: false)
        }
    }
    
    // MARK: SlideOutController delegate method
    func preferenceUpdated() {
        mainViewController.didUpdateLocation()
        mainViewController.didUpdateWeather()
    }
    
    // MARK: Container view management method
    func addPreferencePaneViewController() {
        if slideOutController == nil {
            slideOutController = UIStoryboard.slideOutController()
            addChildSlideOutController(slideOutController!)
//            SlideOutController!.delegate = self
            
        }
    }
    func animatePreferencePane(#shouldExpand: Bool) {
        // # is to have the external parameter name match the variable name
        if (shouldExpand) {
            currentState = .PreferenceExpanded
            let targetPosition = expandedOffset()
            animateMainViewXPosition(targetPosition:  targetPosition)
        } else {
            animateMainViewXPosition(targetPosition: 0) { finished in
                self.currentState = .PreferenceCollapsed
                self.slideOutController!.view.removeFromSuperview()
                self.slideOutController = nil
            }
        }
    }
    
    func addChildSlideOutController(preferenceController: SlideOutController) {
        view.insertSubview(preferenceController.view, atIndex: 0)
        addChildViewController(preferenceController)
        preferenceController.didMoveToParentViewController(self)
    }
    
    // TODO: check out the completion closure format
    func animateMainViewXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
            options: .CurveEaseInOut,
            animations: {
                self.mainViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForMainView(shouldShowShadow: Bool) {
        if (shouldShowShadow){
            mainViewController.view.layer.shadowOpacity = 0.8
        } else {
            mainViewController.view.layer.shadowOpacity = 0
        }
    }
    
    
    // MARK: Gesture recognizer
    func handlePanGesture(sender: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (sender.velocityInView(view).x > 0)
        
        switch sender.state {
        case .Began:
            if (currentState == .PreferenceCollapsed) {
                if gestureIsDraggingFromLeftToRight {
                    addPreferencePaneViewController()
                    showShadowForMainView(true)
                }
            }
        case .Changed:
            if (slideOutController != nil) {
                    sender.view!.center.x = sender.view!.center.x + sender.translationInView(view).x
                    sender.setTranslation(CGPointZero, inView: view)

            }
        case .Ended:
            if (slideOutController != nil) {
                let hasMovedGreaterThanHalfway = sender.view!.center.x > view.bounds.size.width
                animatePreferencePane(shouldExpand: hasMovedGreaterThanHalfway)

            }
        default:
            break
            
        }

    }
    
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func mainViewController() -> DashboardViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MainViewController") as? DashboardViewController
    }
    
    class func slideOutController() -> SlideOutController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SlideOutController") as? SlideOutController
    }

}