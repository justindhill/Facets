//
//  OZLIssueSectionHeaderView.swift
//  Facets
//
//  Created by Justin Hill on 11/27/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

@objc class OZLIssueSectionHeaderView: UIView {

    let sectionTitleLabel = OZLTableViewCell.labelConfiguredForTitle()
    var contentPadding: CGFloat = 0.0
    private var isFirstLayout = true
    
    override func layoutSubviews() {
        if self.isFirstLayout {
            self.addSubview(self.sectionTitleLabel)
            self.isFirstLayout = false
        }
        
        self.sectionTitleLabel.sizeToFit()
        
        self.sectionTitleLabel.frame.origin.x = self.contentPadding
        self.sectionTitleLabel.frame.origin.y = self.frame.size.height - self.sectionTitleLabel.frame.size.height
    }

}
