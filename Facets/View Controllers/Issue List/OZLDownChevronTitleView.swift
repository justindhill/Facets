//
//  OZLDownChevronTitleView.swift
//  Facets
//
//  Created by Justin Hill on 5/28/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit
import SnapKit

class OZLDownChevronTitleView: UIControl {

    private(set) var titleLabel = UILabel()
    private(set) var chevronImageView = UIImageView(image: UIImage(named: "icon-chevron-down"))

    var title: String? {
        set(value) {
            self.titleLabel.text = value?.uppercaseString
            self.setNeedsLayout()
        }
        get {
            return self.titleLabel.text
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.titleLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightSemibold)
        self.autoresizingMask = []

        self.addSubview(self.titleLabel)
        self.addSubview(self.chevronImageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.titleLabel.sizeToFit()

        if self.titleLabel.frame.size.width > self.frame.size.width {
            self.titleLabel.frame.size.width = self.frame.size.width
        }

        self.titleLabel.frame.origin = CGPointMake(ceil((self.frame.size.width - self.titleLabel.frame.size.width) / 2.0), 0)

        self.chevronImageView.sizeToFit()

        self.chevronImageView.frame.origin = CGPointMake(ceil((self.frame.size.width - self.chevronImageView.frame.size.width) / 2.0), self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height)
    }

    override func sizeThatFits(size: CGSize) -> CGSize {
        self.frame.size = size
        self.layoutSubviews()

        let newSize = CGSizeMake(self.titleLabel.frame.size.width, self.chevronImageView.frame.origin.y + self.chevronImageView.frame.size.height)

        return newSize
    }

    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
