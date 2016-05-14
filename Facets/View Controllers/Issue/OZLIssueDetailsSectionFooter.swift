//
//  OZLIssueDetailsSectionFooter.swift
//  Facets
//
//  Created by Justin Hill on 5/8/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit
import SnapKit

class OZLIssueDetailsSectionFooter: UIView {
    let leftButton = UIButton(type: .System)

    private let FontSize: CGFloat = 12.0

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.preservesSuperviewLayoutMargins = true

        self.addSubview(self.leftButton)

        self.leftButton.titleLabel?.font = UIFont.systemFontOfSize(FontSize)
        self.installConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func installConstraints() {
        self.leftButton.snp_makeConstraints { (make) in
            make.leading.equalTo(self.snp_leadingMargin)
            make.bottom.equalTo(self.snp_bottomMargin)
        }
    }
}
