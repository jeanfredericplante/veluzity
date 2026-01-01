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

class ContainerViewController: UIViewController, ViewControllerDelegate, SlideOutDelegate, UIGestureRecognizerDelegate {
    
    struct Constants {
        static let SlideOutExpandedOffset: CGFloat = 270
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
    
     // MARK: Lifecycle  methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainViewController = UIStoryboard.mainViewController()
        mainViewController.view.layer.shadowOffset = CGSize(width: 0,height: 3)
        mainViewController.delegate = self
        
        // Sets up view controller for the dashboard, and hierarchy
        mainViewNavigationController = UINavigationController(rootViewController: mainViewController)
        self.view.addSubview(mainViewController.view)
        addChild(mainViewController)
        mainViewController.didMove(toParent: self)
        
        // adds tap gesture detection
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        mainViewController.view.addGestureRecognizer(panGestureRecognizer)
        print(" supported orientations \(self.supportedInterfaceOrientations)")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        closeSlideOut()
    }
    
    
     // MARK: Container view management method
    func addSlideOutViewController() {
        if slideOutController == nil {
            slideOutController = UIStoryboard.slideOutController()
            addChildSlideOutController(preferenceController: slideOutController!)
            slideOutController!.delegate = self
            
        }
    }
    
   
    func addChildSlideOutController(preferenceController: SlideOutController) {
        view.insertSubview(preferenceController.view, at: 0)
        addChild(preferenceController)
        preferenceController.didMove(toParent: self)
    }

    
    func toggleSlideOut() {
        let notAlreadyExpanded = (currentState != SlideOutState.PreferenceExpanded)
        let shouldI = notAlreadyExpanded
        if notAlreadyExpanded {
            addSlideOutViewController()
        }
        animateSlideOut(shouldExpand: shouldI)
    }
    
    func closeSlideOut() {
        if currentState == SlideOutState.PreferenceExpanded {
            animateSlideOut(shouldExpand: false)
        }
    }
    
    func expandedOffset() -> CGFloat {
        return Constants.SlideOutExpandedOffset
    }
    

    func animateSlideOut(shouldExpand: Bool) {
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
    
    func animateMainViewXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
            options: .curveEaseInOut,
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
    @objc func handlePanGesture(sender: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (sender.velocity(in: view).x > 0)
        
        switch sender.state {
        case .began:
            if (currentState == .PreferenceCollapsed) {
                if gestureIsDraggingFromLeftToRight {
                    addSlideOutViewController()
                    showShadowForMainView(shouldShowShadow: true)
                }
            }
        case .changed:
            if (slideOutController != nil) {
                    sender.view!.center.x = sender.view!.center.x + sender.translation(in: view).x
                    sender.setTranslation(CGPoint.zero, in: view)

            }
        case .ended:
            if (slideOutController != nil) {
                let hasMovedGreaterThanHalfway = sender.view!.center.x > view.bounds.size.width
                animateSlideOut(shouldExpand: hasMovedGreaterThanHalfway)

            }
        default:
            break
            
        }

    }
    
    // MARK: unwind from preference pane
    @IBAction func unwindToContainerViewController(sender: UIStoryboardSegue) {
        if let sourceViewController: AnyObject = sender.sourceViewController as? UIViewController {
            if let storyboardId = sender.identifier {
                switch storyboardId {
                case "dismissAboutUs":
                    sourceViewController.dismiss(animated: true, completion: nil)

                case "dismissPreferencePaneController":
                    print("in pref pane")
                    sourceViewController.dismiss(animated: true, completion: {self.preferenceUpdated()})
                default:
                    break
                }
            }
        }
    }
    
   func preferenceUpdated() {
        mainViewController.didUpdateLocation()
        mainViewController.didUpdateWeather()
    }
    


}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    class func mainViewController() -> DashboardViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "MainViewController") as? DashboardViewController
    }
    
    class func slideOutController() -> SlideOutController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SlideOutController") as? SlideOutController
    }
    
    class func preferencePaneController() -> PreferencePaneController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "PreferencePaneController") as? PreferencePaneController
    }
    
    class func aboutUsController() -> AboutUsController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "AboutUsController") as? AboutUsController
    }

}
