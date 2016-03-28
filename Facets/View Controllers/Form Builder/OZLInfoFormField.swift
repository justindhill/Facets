//
//  OZLInfoFormField.swift
//  News
//
//  Created by Justin Hill on 3/18/16.
//  Copyright © 2016 Frankly, Inc. All rights reserved.
//

class OZLInfoFormField: OZLFormField {
    var valueText: String?
    var titleColor: UIColor
    var valueColor: UIColor

    init(keyPath: String, placeholder: String, valueText: String? = nil,
        titleColor: UIColor = UIColor.blackColor(), valueColor: UIColor = UIColor.lightGrayColor()) {

            self.titleColor = titleColor
            self.valueColor = valueColor
            self.valueText = valueText

            super.init(keyPath: keyPath, placeholder: placeholder)

            self.fieldHeight = 44.0
            self.cellClass = OZLInfoFormFieldCell.self
    }
}

class OZLInfoFormFieldCell: OZLFormFieldCell {

    var titleLabel = UILabel()
    var valueLabel = UILabel()

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup() {
        self.titleLabel.font = UIFont.systemFontOfSize(17.0)
        self.valueLabel.font = UIFont.systemFontOfSize(17.0)
    }

    override func applyFormField(field: OZLFormField) {
        super.applyFormField(field)

        guard let field = field as? OZLInfoFormField else {
            assertionFailure("Somehow got passed the wrong type of form field")
            return
        }

        self.titleLabel.text = field.placeholder
        self.titleLabel.textColor = field.titleColor
        self.valueLabel.text = field.valueText
        self.valueLabel.textColor = field.valueColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.titleLabel.superview == nil {
            self.contentView.addSubview(self.titleLabel)
            self.contentView.addSubview(self.valueLabel)
        }

        self.titleLabel.sizeToFit()
        self.titleLabel.frame.origin = CGPointMake(
            self.contentPadding,
            (self.contentView.frame.size.height - self.titleLabel.frame.size.height) / 2.0
        )

        self.valueLabel.hidden = (self.titleLabel.text?.isEmpty ?? true)

        if !self.valueLabel.hidden {
            self.valueLabel.sizeToFit()
            self.valueLabel.frame.origin = CGPointMake(
                self.contentView.frame.size.width - self.valueLabel.frame.size.width - self.contentPadding,
                (self.contentView.frame.size.height - self.valueLabel.frame.size.height) / 2.0
            )
        }
    }
}
