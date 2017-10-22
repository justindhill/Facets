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

    fileprivate(set) var titleLabel = UILabel()
    fileprivate(set) var chevronImageView = UIImageView(image: UIImage(named: "icon-chevron-down"))

    var title: String? {
        set(value) {
            self.titleLabel.text = value
            self.setNeedsLayout()
        }
        get {
            return self.titleLabel.text
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.titleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
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

        self.titleLabel.frame.origin = CGPoint(x: ceil((self.frame.size.width - self.titleLabel.frame.size.width) / 2.0), y: 0)

        self.chevronImageView.sizeToFit()

        self.chevronImageView.frame.origin = CGPoint(x: ceil((self.frame.size.width - self.chevronImageView.frame.size.width) / 2.0), y: self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height)
    }


    func shrinkwrapContent() {
        self.frame.size.width = UIScreen.main.bounds.size.width
        self.layoutSubviews()

        let newSize = CGSize(width: self.titleLabel.frame.size.width, height: self.chevronImageView.frame.origin.y + self.chevronImageView.frame.size.height)

        self.frame.size = newSize
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
