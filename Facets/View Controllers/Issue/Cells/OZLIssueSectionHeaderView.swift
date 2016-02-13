//
//  OZLIssueSectionHeaderView.swift
//  Facets
//
//  Created by Justin Hill on 11/27/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

@objc class OZLIssueSectionHeaderView: UIView {

    let titleLabel = UILabel()
    let disclosureButton = UIButton(type: .Custom)
    
    var contentPadding: CGFloat = 0.0
    private var isFirstLayout = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel.font = UIFont.systemFontOfSize(14)
        self.titleLabel.textColor = UIColor.lightGrayColor()
        
        self.disclosureButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        self.disclosureButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        self.disclosureButton.contentVerticalAlignment = .Bottom
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        if self.isFirstLayout {
            self.addSubview(self.titleLabel)
            self.addSubview(self.disclosureButton)
            self.isFirstLayout = false
        }
        
        self.titleLabel.sizeToFit()
        self.disclosureButton.sizeToFit()
        
        self.titleLabel.frame.origin.x = ceil(self.contentPadding)
        self.titleLabel.frame.origin.y = ceil(self.frame.size.height - self.titleLabel.frame.size.height)
        
        self.disclosureButton.frame.origin.x = ceil(self.frame.size.width - self.disclosureButton.frame.size.width - self.contentPadding)
        
        // Magic numbers suck, but 5 points further down because UIButton doesn't allow text to butt against edges
        self.disclosureButton.frame.origin.y = ceil(self.frame.size.height - self.disclosureButton.frame.size.height + 5)
    }
}
