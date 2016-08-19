//
//  OZLDropdownPresentationController.swift
//  Facets
//
//  Created by Justin Hill on 5/27/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLDropdownPresentationController: UIPresentationController, UIGestureRecognizerDelegate {
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

    override func shouldPresentInFullscreen() -> Bool {
        return false
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ (context) in
            self.presentedViewController.view.frame = CGRectMake(0, self.presentedOriginY, self.navigationController.view.frame.size.width, self.presentedViewController.preferredContentSize.height)

            let toPath = self.computeDimmingLayerPath(CGSizeMake(self.navigationController.view.frame.size.width, self.presentedOriginY + self.presentedViewController.preferredContentSize.height))

            let AnimKey = "pathAnim"

            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.dimmingLayer.path = toPath
                self.dimmingLayer.removeAnimationForKey(AnimKey)
            }
            CATransaction.setAnimationDuration(coordinator.transitionDuration())
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))

            let anim = CABasicAnimation(keyPath: "path")
            anim.toValue = toPath
            anim.fillMode = kCAFillModeForwards
            anim.removedOnCompletion = false
            
            self.dimmingLayer.addAnimation(anim, forKey: AnimKey)
        }, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        if let containerView = self.containerView {
            self.dimmingLayer.frame = containerView.bounds
            self.dimmingLayer.fillColor = UIColor.clearColor().CGColor
            self.dimmingLayer.opacity = 0.3
            self.dimmingLayer.fillRule = kCAFillRuleEvenOdd

            let initialPath = self.computeDimmingLayerPath(CGSizeMake(self.navigationController.view.frame.size.width, self.presentedOriginY))
            self.dimmingLayer.path = initialPath

            self.presentedViewController.viewWillAppear(true)

            let finalPath = self.computeDimmingLayerPath(CGSizeMake(self.navigationController.view.frame.size.width, self.presentedOriginY + self.presentedViewController.preferredContentSize.height))

            containerView.userInteractionEnabled = true

            self.backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapAction))
            self.backgroundTapRecognizer?.delegate = self
            containerView.addGestureRecognizer(self.backgroundTapRecognizer!)
            containerView.layer.addSublayer(self.dimmingLayer)

            self.presentingViewController.transitionCoordinator()?.animateAlongsideTransition({ (context) in

                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    self.dimmingLayer.fillColor = UIColor.blackColor().CGColor
                    self.dimmingLayer.path = finalPath
                    self.dimmingLayer.removeAllAnimations()
                })

                let group = CAAnimationGroup()
                group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                group.duration = context.transitionDuration()
                group.fillMode = kCAFillModeForwards
                group.removedOnCompletion = false

                let fillColorAnim = CABasicAnimation(keyPath: "fillColor")
                fillColorAnim.fromValue = UIColor.clearColor().CGColor
                fillColorAnim.toValue = UIColor.blackColor().CGColor

                let pathAnim = CABasicAnimation(keyPath: "path")
                pathAnim.fromValue = initialPath
                pathAnim.toValue = finalPath

                group.animations = [fillColorAnim, pathAnim]

                self.dimmingLayer.addAnimation(group, forKey: nil)

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

                let initialPath = self.dimmingLayer.path
                let finalPath = self.computeDimmingLayerPath(CGSizeMake(self.navigationController.view.frame.size.width, self.presentedOriginY))

                let group = CAAnimationGroup()
                group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                group.duration = context.transitionDuration()
                group.fillMode = kCAFillModeForwards
                group.removedOnCompletion = false

                let fillColorAnim = CABasicAnimation(keyPath: "fillColor")
                fillColorAnim.fromValue = UIColor.blackColor().CGColor
                fillColorAnim.toValue = UIColor.clearColor().CGColor

                let pathAnim = CABasicAnimation(keyPath: "path")
                pathAnim.fromValue = initialPath
                pathAnim.toValue = finalPath

                group.animations = [fillColorAnim, pathAnim]

                self.dimmingLayer.addAnimation(group, forKey: nil)

                CATransaction.commit()

            }, completion: nil)
    }

    func computeDimmingLayerPath(cutoutSize: CGSize) -> CGPath {
        let screenBounds = UIScreen.mainScreen().bounds
        let sideLen = max(screenBounds.size.height, screenBounds.size.width)
        let path = UIBezierPath(rect: CGRectMake(0, 0, sideLen, sideLen))
        path.usesEvenOddFillRule = true

        path.appendPath(UIBezierPath(rect: CGRectMake(0, 0, cutoutSize.width, cutoutSize.height)))

        return path.CGPath
    }

    func backgroundTapAction() {
        self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }

    override func frameOfPresentedViewInContainerView() -> CGRect {
        return CGRectMake(0, self.presentedOriginY, self.navigationController.view.frame.size.width, self.presentedViewController.preferredContentSize.height)
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if self.containerView?.hitTest(touch.locationInView(self.containerView), withEvent: nil) != self.containerView {
            return false
        }

        return true
    }
}
