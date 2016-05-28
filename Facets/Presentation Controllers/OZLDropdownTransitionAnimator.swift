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

        toViewController.view.clipsToBounds = true
        let expandedFrame = transitionContext.finalFrameForViewController(toViewController)
        if self.presenting {
            transitionContext.containerView()?.addSubview(toViewController.view)
            toViewController.view.frame = expandedFrame
            toViewController.view.bounds.origin = CGPointMake(0, expandedFrame.size.height)
        }

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            transitionContext.completeTransition(true)
        }

        let positionAnim = CABasicAnimation(keyPath: "bounds.origin")
        positionAnim.fromValue = NSValue(CGPoint: self.presenting ? CGPointMake(0, 2 * expandedFrame.size.height) : CGPointMake(0, fromViewController.view.frame.size.height))
        positionAnim.toValue = NSValue(CGPoint: self.presenting ? CGPointMake(0, expandedFrame.size.height) : CGPointMake(0, 2 * fromViewController.view.frame.size.height))
        positionAnim.duration = self.transitionDuration(transitionContext)
        positionAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        positionAnim.fillMode = kCAFillModeForwards
        positionAnim.removedOnCompletion = false

        if self.presenting {
            toViewController.view.layer.addAnimation(positionAnim, forKey: nil)
        } else {
            fromViewController.view.layer.addAnimation(positionAnim, forKey: nil)
        }

        CATransaction.commit()
    }
}
