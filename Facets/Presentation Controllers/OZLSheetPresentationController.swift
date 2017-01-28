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
            self.dimmingView.backgroundColor = UIColor.black
            self.dimmingView.alpha = 0.0
            self.dimmingView.isUserInteractionEnabled = true
            
            self.dimmingView.addGestureRecognizer(self.backgroundTapRecognizer)
            self.backgroundTapRecognizer.addTarget(self, action: #selector(OZLSheetPresentationController.backgroundTapAction))
        
            self.presentingViewController.transitionCoordinator?.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                
                self.dimmingView.alpha = 0.3
                }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentingViewController.transitionCoordinator?.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.dimmingView.alpha = 0.0
            }, completion: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.dimmingView.removeFromSuperview()
        })
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.containerViewWillLayoutSubviews()
            self.containerView?.layoutSubviews()
            self.containerViewDidLayoutSubviews()
        }) 
    }
    
    override func containerViewWillLayoutSubviews() {
        self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
    }
    
    override var frameOfPresentedViewInContainerView : CGRect {
        if let containerView = self.containerView {
            let preferredHeight = self.presentedViewController.preferredContentSize.height
            return CGRect(x: 0, y: containerView.frame.size.height - preferredHeight, width: containerView.frame.size.width, height: preferredHeight)
        }
        
        return CGRect.zero
    }
    
    func backgroundTapAction() {
        self.presentingViewController.dismiss(animated: true, completion: nil)
    }
}
