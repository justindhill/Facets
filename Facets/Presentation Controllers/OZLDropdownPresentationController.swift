//
//  OZLDropdownPresentationController.swift
//  Facets
//
//  Created by Justin Hill on 5/27/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLDropdownPresentationController: UIPresentationController, UIGestureRecognizerDelegate {
    fileprivate(set) var dimmingLayer = CAShapeLayer()
    fileprivate var backgroundTapRecognizer: UITapGestureRecognizer?
    fileprivate(set) var navigationController: UINavigationController

    fileprivate var presentedOriginY: CGFloat {
        let navBar = self.navigationController.navigationBar

        return navBar.frame.origin.y + navBar.frame.size.height + (1 / self.traitCollection.displayScale)
    }

    init(presentedViewController: UIViewController, presentingViewController: UIViewController?, navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override var shouldPresentInFullscreen : Bool {
        return false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            self.presentedViewController.view.frame = CGRect(x: 0, y: self.presentedOriginY, width: self.navigationController.view.frame.size.width, height: self.presentedViewController.preferredContentSize.height)

            let toPath = self.computeDimmingLayerPath(CGSize(width: self.navigationController.view.frame.size.width, height: self.presentedOriginY + self.presentedViewController.preferredContentSize.height))

            let AnimKey = "pathAnim"

            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.dimmingLayer.path = toPath
                self.dimmingLayer.removeAnimation(forKey: AnimKey)
            }
            CATransaction.setAnimationDuration(coordinator.transitionDuration)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))

            let anim = CABasicAnimation(keyPath: "path")
            anim.toValue = toPath
            anim.fillMode = kCAFillModeForwards
            anim.isRemovedOnCompletion = false
            
            self.dimmingLayer.add(anim, forKey: AnimKey)
        }, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        if let containerView = self.containerView {
            self.dimmingLayer.frame = containerView.bounds
            self.dimmingLayer.fillColor = UIColor.clear.cgColor
            self.dimmingLayer.opacity = 0.3
            self.dimmingLayer.fillRule = kCAFillRuleEvenOdd

            let initialPath = self.computeDimmingLayerPath(CGSize(width: self.navigationController.view.frame.size.width, height: self.presentedOriginY))
            self.dimmingLayer.path = initialPath

            self.presentedViewController.viewWillAppear(true)

            let finalPath = self.computeDimmingLayerPath(CGSize(width: self.navigationController.view.frame.size.width, height: self.presentedOriginY + self.presentedViewController.preferredContentSize.height))

            containerView.isUserInteractionEnabled = true

            self.backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapAction))
            self.backgroundTapRecognizer?.delegate = self
            containerView.addGestureRecognizer(self.backgroundTapRecognizer!)
            containerView.layer.addSublayer(self.dimmingLayer)

            self.presentingViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in

                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    self.dimmingLayer.fillColor = UIColor.black.cgColor
                    self.dimmingLayer.path = finalPath
                    self.dimmingLayer.removeAllAnimations()
                })

                let group = CAAnimationGroup()
                group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                group.duration = context.transitionDuration
                group.fillMode = kCAFillModeForwards
                group.isRemovedOnCompletion = false

                let fillColorAnim = CABasicAnimation(keyPath: "fillColor")
                fillColorAnim.fromValue = UIColor.clear.cgColor
                fillColorAnim.toValue = UIColor.black.cgColor

                let pathAnim = CABasicAnimation(keyPath: "path")
                pathAnim.fromValue = initialPath
                pathAnim.toValue = finalPath

                group.animations = [fillColorAnim, pathAnim]

                self.dimmingLayer.add(group, forKey: nil)

                CATransaction.commit()
            }, completion: nil)
        }
    }

    override func dismissalTransitionWillBegin() {
        self.presentingViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in

                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    self.dimmingLayer.fillColor = UIColor.clear.cgColor
                    self.dimmingLayer.removeAllAnimations()
                })

                let initialPath = self.dimmingLayer.path
                let finalPath = self.computeDimmingLayerPath(CGSize(width: self.navigationController.view.frame.size.width, height: self.presentedOriginY))

                let group = CAAnimationGroup()
                group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                group.duration = context.transitionDuration
                group.fillMode = kCAFillModeForwards
                group.isRemovedOnCompletion = false

                let fillColorAnim = CABasicAnimation(keyPath: "fillColor")
                fillColorAnim.fromValue = UIColor.black.cgColor
                fillColorAnim.toValue = UIColor.clear.cgColor

                let pathAnim = CABasicAnimation(keyPath: "path")
                pathAnim.fromValue = initialPath
                pathAnim.toValue = finalPath

                group.animations = [fillColorAnim, pathAnim]

                self.dimmingLayer.add(group, forKey: nil)

                CATransaction.commit()

            }, completion: nil)
    }

    func computeDimmingLayerPath(_ cutoutSize: CGSize) -> CGPath {
        let screenBounds = UIScreen.main.bounds
        let sideLen = max(screenBounds.size.height, screenBounds.size.width)
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: sideLen, height: sideLen))
        path.usesEvenOddFillRule = true

        path.append(UIBezierPath(rect: CGRect(x: 0, y: 0, width: cutoutSize.width, height: cutoutSize.height)))

        return path.cgPath
    }

    func backgroundTapAction() {
        self.presentingViewController.dismiss(animated: true, completion: nil)
    }

    override var frameOfPresentedViewInContainerView : CGRect {
        return CGRect(x: 0, y: self.presentedOriginY, width: self.navigationController.view.frame.size.width, height: self.presentedViewController.preferredContentSize.height)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if self.containerView?.hitTest(touch.location(in: self.containerView), with: nil) != self.containerView {
            return false
        }

        return true
    }
}
