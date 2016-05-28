//
//  OZLDropdownPresentationController.swift
//  Facets
//
//  Created by Justin Hill on 5/27/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLDropdownPresentationController: UIPresentationController {
    private(set) var dimmingLayer = CAShapeLayer()
    private var backgroundTapRecognizer: UITapGestureRecognizer?
    private(set) var navigationController: UINavigationController

    private var presentedOriginY: CGFloat {
        let navBar = self.navigationController.navigationBar

        return navBar.frame.origin.y + navBar.frame.size.height + (1 / self.traitCollection.displayScale)
    }

    init(presentedViewController: UIViewController, presentingViewController: UIViewController, navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ (context) in
            UIView.performWithoutAnimation({ 
                self.updateDimmingLayerPath()
                self.presentedViewController.view.frame = CGRectMake(0, self.presentedOriginY, self.navigationController.view.frame.size.width, 400)
            })

        }, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        if let containerView = self.containerView {
            self.dimmingLayer.frame = containerView.bounds
            self.dimmingLayer.fillColor = UIColor.clearColor().CGColor
            self.dimmingLayer.opacity = 0.8
            self.dimmingLayer.fillRule = kCAFillRuleEvenOdd

            self.updateDimmingLayerPath()

            containerView.userInteractionEnabled = true

            self.backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapAction))
            containerView.addGestureRecognizer(self.backgroundTapRecognizer!)
            containerView.layer.addSublayer(self.dimmingLayer)

            self.presentingViewController.transitionCoordinator()?.animateAlongsideTransition({ (context) in

                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    self.dimmingLayer.fillColor = UIColor.blackColor().CGColor
                    self.dimmingLayer.removeAllAnimations()
                })

                let anim = CABasicAnimation(keyPath: "fillColor")
                anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                anim.fromValue = UIColor.clearColor().CGColor
                anim.toValue = UIColor.blackColor().CGColor
                anim.duration = context.transitionDuration()
                anim.fillMode = kCAFillModeForwards
                anim.removedOnCompletion = false

                self.dimmingLayer.addAnimation(anim, forKey: nil)

                CATransaction.commit()
            }, completion: nil)
        }
    }

    override func dismissalTransitionWillBegin() {
        self.presentingViewController.transitionCoordinator()?.animateAlongsideTransition({ (context) in

                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    self.dimmingLayer.fillColor = UIColor.clearColor().CGColor
                    self.dimmingLayer.removeAllAnimations()
                })

                let anim = CABasicAnimation(keyPath: "fillColor")
                anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                anim.fromValue = UIColor.blackColor().CGColor
                anim.toValue = UIColor.clearColor().CGColor
                anim.duration = context.transitionDuration()
                anim.fillMode = kCAFillModeForwards
                anim.removedOnCompletion = false

                self.dimmingLayer.addAnimation(anim, forKey: nil)

                CATransaction.commit()

            }, completion: nil)
    }

    func updateDimmingLayerPath() {
        let screenBounds = UIScreen.mainScreen().bounds
        let sideLen = max(screenBounds.size.height, screenBounds.size.width)
        let path = UIBezierPath(rect: CGRectMake(0, 0, sideLen, sideLen))
        path.usesEvenOddFillRule = true
        path.appendPath(UIBezierPath(rect: CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.presentedOriginY)))
        self.dimmingLayer.path = path.CGPath
    }

    func backgroundTapAction() {
        self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }

    override func frameOfPresentedViewInContainerView() -> CGRect {
        return CGRectMake(0, self.presentedOriginY, self.navigationController.view.frame.size.width, 400)
    }
}
