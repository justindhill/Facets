//
//  OZLQuickAssignView.swift
//  Facets
//
//  Created by Justin Hill on 12/14/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class OZLQuickAssignView: UIView {
    let filterField = JVFloatLabeledTextField()
    let filterDivider = UIView()
    let cancelDivider = UIView()
    let cancelButton = UIButton(type: .System)
    let tableView = UITableView(frame: CGRectZero, style: .Plain)
    
    private let loadingOverlay = OZLLoadingView()
    
    var contentPadding: CGFloat = 16.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizingMask = .FlexibleWidth
        
        self.filterField.placeholder = "Filter"
        self.filterField.contentVerticalAlignment = .Center
        self.filterField.returnKeyType = .Done
        self.filterField.clearButtonMode = .Always
        
        self.filterDivider.backgroundColor = UIColor.OZLVeryLightGrayColor()
        self.cancelDivider.backgroundColor = UIColor.OZLVeryLightGrayColor()
        
        self.cancelButton.setTitle("Cancel", forState: .Normal)
        self.cancelButton.titleLabel?.font = UIFont.systemFontOfSize(17)
        
        self.loadingOverlay.backgroundColor = UIColor(white: 1.0, alpha: 0.75)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if self.filterField.superview == nil {
            self.addSubview(self.tableView)
            self.addSubview(self.filterField)
            self.addSubview(self.filterDivider)
            self.addSubview(self.cancelButton)
            self.addSubview(self.cancelDivider)
        }
        
        self.filterField.frame.origin.y = 0
        self.filterField.frame.origin.x = self.contentPadding
        self.filterField.frame.size.width = self.frame.size.width - (2 * self.contentPadding)
        self.filterField.frame.size.height = 44.0
        self.filterField.floatingLabelYPadding = 5.0
        
        self.filterDivider.frame = CGRectMake(0, self.filterField.bottom, self.frame.size.width, 1.0)
        
        self.cancelButton.sizeToFit()
        self.cancelButton.frame.origin.x = (self.frame.size.width - self.cancelButton.frame.size.width) / 2.0
        self.cancelButton.frame.origin.y = ((44.0 - self.cancelButton.frame.size.height) / 2.0) + self.frame.size.height - 44.0
        
        self.cancelDivider.frame = CGRectMake(0, self.frame.size.height - 44.0, self.frame.size.width, 1.0)
        
        self.tableView.frame = CGRectMake(0, self.filterDivider.bottom, self.frame.size.width, self.cancelDivider.top - self.filterDivider.bottom)
        
        self.loadingOverlay.frame = self.bounds
    }
    
    func showLoadingOverlay() {
        if self.loadingOverlay.superview == nil {
            self.addSubview(self.loadingOverlay)
            self.loadingOverlay.frame = self.bounds
            self.filterField.resignFirstResponder()
        }

        self.loadingOverlay.startLoading()
    }
    
    func hideLoadingOverlay() {
        if self.loadingOverlay.superview != nil {
            self.loadingOverlay.removeFromSuperview()
            self.loadingOverlay.endLoading()
        }
    }
}
