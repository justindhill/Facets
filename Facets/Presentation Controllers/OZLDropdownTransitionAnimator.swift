//
//  OZLDropdownTransitionAnimator.swift
//  Facets
//
//  Created by Justin Hill on 5/27/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLDropdownTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var navigationController: UINavigationController
    var presenting = true

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }

    private var presentedOriginY: CGFloat {
        let navBar = self.navigationController.navigationBar
        return navBar.frame.origin.y + navBar.frame.size.height + (1 / navigationController.traitCollection.displayScale)
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
            assertionFailure("No toViewController!")
            return
        }

        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else {
            assertionFailure("No fromViewController!")
            return
        }

        let collapsedFrame = CGRectMake(0, self.presentedOriginY, self.navigationController.view.frame.size.width, 0)

        if self.presenting {
            transitionContext.containerView()?.addSubview(toViewController.view)
            toViewController.view.frame = collapsedFrame
        }

        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, options: [ .CurveEaseOut ], animations: { 

                if self.presenting {
                    toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
                } else {
                    fromViewController.view.frame = collapsedFrame
                }
            }) { (finished) in
                transitionContext.completeTransition(true)
        }
    }
}
