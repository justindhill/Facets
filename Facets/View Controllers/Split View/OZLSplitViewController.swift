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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.viewControllers = [ self.masterNavigationController, self.detailNavigationController ]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.traitCollection.userInterfaceIdiom == .Pad {
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
    
    override func showViewController(vc: UIViewController, sender: AnyObject?) {
        if self.traitCollection.horizontalSizeClass == .Compact || vc.view.tag == OZLSplitViewController.PrimaryPaneMember {
            self.masterNavigationController.pushViewController(vc, animated: true)
        } else {
            self.detailNavigationController.viewControllers = [ vc ]
        }
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        
        if secondaryViewController == self.detailNavigationController {
            if self.detailNavigationController.viewControllers.count > 0 {
                if self.detailNavigationController.viewControllers.first!.isKindOfClass(OZLSplitViewPlaceholderPane.self) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        
        
        if let last = self.masterNavigationController.viewControllers.last where last.isKindOfClass(UINavigationController.self) {
            if last != self.detailNavigationController {
                assertionFailure("The last vc in the master nav is definitely not what we're expecting");
            }
            
        } else if (self.viewControllers.count == 1) {
            // the secondary navigation controller got popped off, so now we need to go looking for where
            // they should be split
            var splitIndex = -1
            var secondaryPaneVCs = [UIViewController]()
            for ele in self.masterNavigationController.viewControllers.enumerate() {
                if ele.element.view.tag != OZLSplitViewController.PrimaryPaneMember && splitIndex < 0 {
                    splitIndex = ele.index
                }
                
                if splitIndex > 0 {
                    secondaryPaneVCs.append(ele.element)
                }
            }
            
            if splitIndex > 0 {
                self.masterNavigationController.viewControllers.removeRange(splitIndex..<self.masterNavigationController.viewControllers.count)
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
