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

    fileprivate var presentedOriginY: CGFloat {
        let navBar = self.navigationController.navigationBar
        return navBar.frame.origin.y + navBar.frame.size.height + (1 / navigationController.traitCollection.displayScale)
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            assertionFailure("No toViewController!")
            return
        }

        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            assertionFailure("No fromViewController!")
            return
        }

        toViewController.view.clipsToBounds = true
        let expandedFrame = transitionContext.finalFrame(for: toViewController)
        if self.presenting {
            transitionContext.containerView.addSubview(toViewController.view)
            toViewController.view.frame = expandedFrame
            toViewController.view.bounds.origin = CGPoint(x: 0, y: expandedFrame.size.height)
        }

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            transitionContext.completeTransition(true)
        }

        let positionAnim = CABasicAnimation(keyPath: "bounds.origin")
        positionAnim.fromValue = NSValue(cgPoint: self.presenting ? CGPoint(x: 0, y: 2 * expandedFrame.size.height) : CGPoint(x: 0, y: fromViewController.view.frame.size.height))
        positionAnim.toValue = NSValue(cgPoint: self.presenting ? CGPoint(x: 0, y: expandedFrame.size.height) : CGPoint(x: 0, y: 2 * fromViewController.view.frame.size.height))
        positionAnim.duration = self.transitionDuration(using: transitionContext)
        positionAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        positionAnim.fillMode = kCAFillModeForwards
        positionAnim.isRemovedOnCompletion = false

        if self.presenting {
            toViewController.view.layer.add(positionAnim, forKey: nil)
        } else {
            fromViewController.view.layer.add(positionAnim, forKey: nil)
        }

        CATransaction.commit()
    }
}
