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
    let leftButton = UIButton(type: .system)

    fileprivate let FontSize: CGFloat = 12.0

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.preservesSuperviewLayoutMargins = true

        self.addSubview(self.leftButton)

        self.leftButton.titleLabel?.font = UIFont.systemFont(ofSize: FontSize)
        self.installConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func installConstraints() {
        self.leftButton.snp.makeConstraints { (make) in
            make.leading.equalTo(self.snp.leadingMargin)
            make.top.equalTo(self)
        }
    }
}
