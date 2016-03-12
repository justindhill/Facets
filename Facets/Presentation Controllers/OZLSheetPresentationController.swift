//
//  OZLSheetPresentationController.swift
//  PresentationController
//
//  Created by Justin Hill on 12/23/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

@objc class OZLSheetPresentationController: UIPresentationController {
    
    let dimmingView = UIView()
    let backgroundTapRecognizer = UITapGestureRecognizer()
    
    override func presentationTransitionWillBegin() {
        
        if let containerView = self.containerView {
            containerView.addSubview(self.dimmingView)
            self.dimmingView.frame = containerView.bounds
            self.dimmingView.backgroundColor = UIColor.blackColor()
            self.dimmingView.alpha = 0.0
            self.dimmingView.userInteractionEnabled = true
            
            self.dimmingView.addGestureRecognizer(self.backgroundTapRecognizer)
            self.backgroundTapRecognizer.addTarget(self, action: #selector(OZLSheetPresentationController.backgroundTapAction))
        
            self.presentingViewController.transitionCoordinator()?.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                
                self.dimmingView.alpha = 0.3
                }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentingViewController.transitionCoordinator()?.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.dimmingView.alpha = 0.0
            }, completion: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.dimmingView.removeFromSuperview()
        })
    }
    
    override func preferredContentSizeDidChangeForChildContentContainer(container: UIContentContainer) {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.containerViewWillLayoutSubviews()
            self.containerView?.layoutSubviews()
            self.containerViewDidLayoutSubviews()
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView()
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        if let containerView = self.containerView {
            let preferredHeight = self.presentedViewController.preferredContentSize.height
            return CGRectMake(0, containerView.frame.size.height - preferredHeight, containerView.frame.size.width, preferredHeight)
        }
        
        return CGRectZero
    }
    
    func backgroundTapAction() {
        self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
