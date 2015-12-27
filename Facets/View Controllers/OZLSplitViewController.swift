//
//  OZLSplitViewController.swift
//  Facets
//
//  Created by Justin Hill on 12/26/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

@objc class OZLSplitViewController: UISplitViewController {
    let masterNavigationController = UINavigationController()
    let detailNavigationController = UINavigationController()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.viewControllers = [ self.masterNavigationController, self.detailNavigationController ]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func showViewController(vc: UIViewController, sender: AnyObject?) {
        if self.traitCollection.horizontalSizeClass == .Compact {
            self.masterNavigationController.pushViewController(vc, animated: true)
        } else {
            self.detailNavigationController.viewControllers = [ vc ]
        }
    }
    
    override func separateSecondaryViewControllerForSplitViewController(splitViewController: UISplitViewController) -> UIViewController? {
        if let last = self.masterNavigationController.viewControllers.last {
            if last.isKindOfClass(UINavigationController.self) {
                return last
            }
        }
        
        return nil
    }
}
