//
//  OZLMainTabControllerViewController.swift
//  Facets
//
//  Created by Justin Hill on 1/1/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLMainTabControllerViewController: UITabBarController, OZLAccountViewControllerDelegate, UITabBarControllerDelegate {
    
    let projectIssuesVC = OZLIssueListViewController(style: .plain)
    let queryListVC = OZLQueryListViewController(style: .plain)
    let settingsVC = OZLAccountViewController(nibName: "OZLAccountViewController", bundle: nil)
    
    let projectSplitView = OZLMainTabControllerViewController.customizedSplitViewController()
    let queryListSplitView = OZLMainTabControllerViewController.customizedSplitViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        self.delegate = self
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = UIColor.white
        
        self.projectIssuesVC.viewModel = OZLIssueListViewModel()
        self.projectIssuesVC.viewModel.shouldShowProjectSelector = true
        self.projectIssuesVC.viewModel.shouldShowComposeButton = true
        self.projectIssuesVC.view.tag = OZLSplitViewController.PrimaryPaneMember
        
        self.settingsVC.delegate = self

        self.projectSplitView.masterNavigationController.viewControllers = [ self.projectIssuesVC ]
        self.projectSplitView.tabBarItem = UITabBarItem(title: "Issues", image: UIImage(named: "icon-list"), tag: 0)
        
        self.queryListSplitView.masterNavigationController.viewControllers = [ self.queryListVC ]
        self.queryListSplitView.tabBarItem = UITabBarItem(title:"Queries", image: UIImage(named: "icon-search"), tag:0)
        
        let settingsNav = UINavigationController(rootViewController: self.settingsVC)
        settingsNav.navigationBar.isTranslucent = false
        settingsNav.navigationBar.barTintColor = UIColor.white
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "icon-cog"), tag: 0)

        let watchingVC = UIViewController()
        watchingVC.title = "Watching"

        let watchingNav = UINavigationController(rootViewController: watchingVC)
        watchingNav.navigationBar.isTranslucent = false
        watchingNav.navigationBar.barTintColor = UIColor.white
        watchingNav.tabBarItem = UITabBarItem(title: "Watching", image: UIImage(named: "icon-eye"), tag: 0)
        
        self.viewControllers = [ self.projectSplitView, self.queryListSplitView, watchingNav, settingsNav ]
        
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
        svc.preferredDisplayMode = .allVisible
        svc.extendedLayoutIncludesOpaqueBars = true
        svc.masterNavigationController.extendedLayoutIncludesOpaqueBars = true
        svc.detailNavigationController.extendedLayoutIncludesOpaqueBars = true
        
        svc.masterNavigationController.navigationBar.isTranslucent = false
        svc.masterNavigationController.navigationBar.barTintColor = UIColor.white
        svc.detailNavigationController.navigationBar.isTranslucent = false
        svc.detailNavigationController.navigationBar.barTintColor = UIColor.white
        
        return svc;
    }
    
    // MARK: OZLAccountViewControllerDelegate
    func accountViewControllerDidSuccessfullyAuthenticate(_ account: OZLAccountViewController!, shouldTransitionToIssues shouldTransition: Bool) {
        if shouldTransition {
            CATransaction.begin()
            
            let transition = CATransition()
            transition.duration = 0.3;
            transition.type = kCATransitionPush;
            transition.subtype = kCATransitionFromLeft;
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.view.layer.add(transition, forKey: nil)
            
            self.selectedIndex = 0
            
            CATransaction.commit()
        }
    }

    // MARK: UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let viewController = viewController as? OZLSplitViewController, viewController == self.selectedViewController {
            viewController.masterNavigationController.popToRootViewController(animated: true)
        }

        return true
    }
}
