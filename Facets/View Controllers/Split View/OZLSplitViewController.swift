//
//  OZLSplitViewController.swift
//  Facets
//
//  Created by Justin Hill on 12/26/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit


@objc class OZLSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    class var PrimaryPaneMember: Int {
        get {
            return 1
        }
    }
    
    let masterNavigationController = UINavigationController()
    let detailNavigationController = UINavigationController()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.viewControllers = [ self.masterNavigationController, self.detailNavigationController ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.traitCollection.userInterfaceIdiom == .pad && self.presentedViewController == nil {
            self.detailNavigationController.viewControllers = [ OZLSplitViewPlaceholderPane() ]
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        if self.traitCollection.horizontalSizeClass == .compact || vc.view.tag == OZLSplitViewController.PrimaryPaneMember {
            self.masterNavigationController.pushViewController(vc, animated: true)
        } else {
            self.detailNavigationController.viewControllers = [ vc ]
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        if secondaryViewController == self.detailNavigationController {
            if self.detailNavigationController.viewControllers.count > 0 {
                if self.detailNavigationController.viewControllers.first!.isKind(of: OZLSplitViewPlaceholderPane.self) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        
        
        if let last = self.masterNavigationController.viewControllers.last, last.isKind(of: UINavigationController.self) {
            if last != self.detailNavigationController {
                assertionFailure("The last vc in the master nav is definitely not what we're expecting");
            }
            
        } else if (self.viewControllers.count == 1) {
            // the secondary navigation controller got popped off, so now we need to go looking for where
            // they should be split
            var splitIndex = -1
            var secondaryPaneVCs = [UIViewController]()
            for (index, ele) in self.masterNavigationController.viewControllers.enumerated() {
                if ele.view.tag != OZLSplitViewController.PrimaryPaneMember && splitIndex < 0 {
                    splitIndex = index
                }
                
                if splitIndex > 0 {
                    secondaryPaneVCs.append(ele)
                }
            }
            
            if splitIndex > 0 {
                self.masterNavigationController.viewControllers.removeSubrange(splitIndex..<self.masterNavigationController.viewControllers.count)
            }
            
            if secondaryPaneVCs.count == 0 {
                self.detailNavigationController.viewControllers = [ OZLSplitViewPlaceholderPane() ]
            } else {
                self.detailNavigationController.viewControllers = secondaryPaneVCs
            }
        }
        
        return self.detailNavigationController
    }
}
