//
//  ContainerViewController.swift
//  Speed
//
//  Created by Jean Frederic Plante on 1/10/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, ViewControllerDelegate {
    
    var mainViewController: ViewController!
    var mainViewNavigationController: UINavigationController!
    
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