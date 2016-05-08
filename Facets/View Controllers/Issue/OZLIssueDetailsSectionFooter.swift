//
//  OZLIssueDetailsSectionFooter.swift
//  Facets
//
//  Created by Justin Hill on 5/8/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLIssueDetailsSectionFooter: UIView {
    let leftButton = UIButton(type: .System)

    private let FontSize: CGFloat = 12.0

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.preservesSuperviewLayoutMargins = true

        self.leftButton.titleLabel?.font = UIFont.systemFontOfSize(FontSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.leftButton.superview == nil {
            self.addSubview(self.leftButton)
        }

        self.leftButton.sizeToFit()

        self.leftButton.frame.origin = CGPointMake(self.layoutMargins.left,
                                                   self.frame.size.height - self.leftButton.frame.size.height - self.layoutMargins.bottom)
    }
}
