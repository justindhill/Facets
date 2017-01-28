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
    let disclosureButton = UIButton(type: .custom)
    
    var contentPadding: CGFloat = 0.0
    fileprivate var isFirstLayout = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.preservesSuperviewLayoutMargins = true
        
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.titleLabel.textColor = UIColor.gray
        
        self.disclosureButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.disclosureButton.setTitleColor(UIColor.gray, for: UIControlState())
        self.disclosureButton.contentVerticalAlignment = .bottom

        self.addSubview(self.titleLabel)
        self.addSubview(self.disclosureButton)

        self.installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func installConstraints() {
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.snp.leadingMargin)
            make.bottom.equalTo(self)
        }

        self.disclosureButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.snp.trailingMargin)
            make.lastBaseline.equalTo(self.titleLabel)
        }
    }
}
