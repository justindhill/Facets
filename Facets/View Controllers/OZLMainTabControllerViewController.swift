//
//  OZLMainTabControllerViewController.swift
//  Facets
//
//  Created by Justin Hill on 1/1/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLMainTabControllerViewController: UITabBarController, OZLAccountViewControllerDelegate {
    
    let projectIssuesVC = OZLIssueListViewController(nibName: "OZLIssueListViewController", bundle: nil)
    let queryListVC = OZLQueryListViewController(nibName: "OZLQueryListViewController", bundle: nil)
    let settingsVC = OZLAccountViewController(nibName: "OZLAccountViewController", bundle: nil)
    
    let projectSplitView = OZLMainTabControllerViewController.customizedSplitViewController()
    let queryListSplitView = OZLMainTabControllerViewController.customizedSplitViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
        
        self.tabBar.translucent = false
        self.tabBar.barTintColor = UIColor.whiteColor()
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.projectIssuesVC.viewModel = OZLIssueListViewModel()
        self.projectIssuesVC.viewModel.shouldShowProjectSelector = true
        self.projectIssuesVC.viewModel.shouldShowComposeButton = true
        self.projectIssuesVC.viewModel.shouldShowProjectSearch = true
        self.projectIssuesVC.view.tag = OZLSplitViewController.PrimaryPaneMember
        
        self.settingsVC.delegate = self
        
        self.projectSplitView.masterNavigationController.viewControllers = [ self.projectIssuesVC ]
        self.projectSplitView.tabBarItem = UITabBarItem(title: "Issues", image: nil, tag: 0)
        
        self.queryListSplitView.masterNavigationController.viewControllers = [ self.queryListVC ]
        self.queryListSplitView.tabBarItem = UITabBarItem(title:"Queries", image:nil, tag:0)
        
        let settingsNav = UINavigationController(rootViewController: self.settingsVC)
        settingsNav.navigationBar.translucent = false
        settingsNav.navigationBar.barTintColor = UIColor.whiteColor()
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: nil, tag: 0)
        
        self.viewControllers = [ self.projectSplitView, self.queryListSplitView, settingsNav ]
        
        if OZLSingleton.sharedInstance().isUserLoggedIn && OZLSingleton.sharedInstance().currentProjectID != NSNotFound {
            self.projectIssuesVC.viewModel.projectId = OZLSingleton.sharedInstance().currentProjectID
            self.selectedViewController = self.projectSplitView
        } else {
            self.selectedViewController = self.settingsVC.navigationController
            self.settingsVC.isFirstLogin = true
        }
    };

    class func customizedSplitViewController() -> OZLSplitViewController {
        let svc = OZLSplitViewController()
        svc.preferredDisplayMode = .AllVisible
        svc.extendedLayoutIncludesOpaqueBars = true
        svc.masterNavigationController.extendedLayoutIncludesOpaqueBars = true
        svc.detailNavigationController.extendedLayoutIncludesOpaqueBars = true
        
        svc.masterNavigationController.navigationBar.translucent = false
        svc.masterNavigationController.navigationBar.barTintColor = UIColor.whiteColor()
        svc.masterNavigationController.view.backgroundColor = UIColor.whiteColor()
        svc.detailNavigationController.navigationBar.barTintColor = UIColor.whiteColor()
        
        return svc;
    }
    
    // MARK: OZLAccountViewControllerDelegate
    func accountViewControllerDidSuccessfullyAuthenticate(account: OZLAccountViewController!, shouldTransitionToIssues shouldTransition: Bool) {
        if shouldTransition {
            CATransaction.begin()
            
            let transition = CATransition()
            transition.duration = 0.3;
            transition.type = kCATransitionPush;
            transition.subtype = kCATransitionFromLeft;
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.view.layer.addAnimation(transition, forKey: nil)
            
            self.selectedIndex = 0
            
            CATransaction.commit()
        }
    }
}
