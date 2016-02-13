//
//  OZLAboutTabFieldView.swift
//  Facets
//
//  Created by Justin Hill on 2/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLAboutTabFieldView: UIView {
    
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    
    let interLabelPadding: CGFloat = 3.0
    
    convenience init(title: String, value: String) {
        self.init()
        
        self.titleLabel.text = title
        self.valueLabel.text = value
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel.textColor = UIColor.lightGrayColor()
        self.titleLabel.font = UIFont.OZLMediumSystemFontOfSize(11.0)
        self.titleLabel.numberOfLines = 1;
        
        self.valueLabel.textColor = UIColor.darkGrayColor()
        self.valueLabel.font = UIFont.systemFontOfSize(14.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.layoutForSize(self.frame.size)
    }
    
    func layoutForSize(size: CGSize) {
        super.layoutSubviews()
        
        if self.titleLabel.superview == nil {
            self.addSubview(self.titleLabel)
            self.addSubview(self.valueLabel)
        }
        
        self.titleLabel.sizeToFit()
        self.titleLabel.frame.size.width = min(size.width, self.titleLabel.frame.size.width)
        self.titleLabel.frame.origin = CGPointMake(0, 0)
        
        self.valueLabel.sizeToFit()
        self.valueLabel.frame.size.width = min(size.width, self.valueLabel.frame.size.width)
        self.valueLabel.frame.origin = CGPointMake(0, self.titleLabel.bottom + self.interLabelPadding)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        self.layoutForSize(size)
        
        let width = max(self.titleLabel.frame.size.width, self.valueLabel.frame.size.width)
        let height = self.titleLabel.frame.size.height + self.valueLabel.frame.size.height + self.interLabelPadding
        
        return CGSizeMake(ceil(width), ceil(height))
    }
}
