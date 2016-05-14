//
//  OZLIssueSectionHeaderView.swift
//  Facets
//
//  Created by Justin Hill on 11/27/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit
import SnapKit

@objc class OZLIssueSectionHeaderView: UIView {

    let titleLabel = UILabel()
    let disclosureButton = UIButton(type: .Custom)
    
    var contentPadding: CGFloat = 0.0
    private var isFirstLayout = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.preservesSuperviewLayoutMargins = true
        
        self.titleLabel.font = UIFont.systemFontOfSize(14)
        self.titleLabel.textColor = UIColor.grayColor()
        
        self.disclosureButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        self.disclosureButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        self.disclosureButton.contentVerticalAlignment = .Bottom

        self.addSubview(self.titleLabel)
        self.addSubview(self.disclosureButton)

        self.installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func installConstraints() {
        self.titleLabel.snp_makeConstraints { (make) in
            make.leading.equalTo(self.snp_leadingMargin)
            make.bottom.equalTo(self)
        }

        self.disclosureButton.snp_makeConstraints { (make) in
            make.trailing.equalTo(self.snp_trailingMargin)
            make.baseline.equalTo(self.titleLabel)
        }
    }
}
