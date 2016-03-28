//
//  OZLSwitchFormField.swift
//  Facets
//
//  Created by Justin Hill on 3/17/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

class OZLSwitchFormField: OZLFormField {

    var currentValue: Bool

    init(keyPath: String, placeholder: String, currentValue: Bool) {
        self.currentValue = currentValue

        super.init(keyPath: keyPath, placeholder: placeholder)

        self.fieldHeight = 48.0
        self.cellClass = OZLSwitchFormFieldCell.self
    }

}

class OZLSwitchFormFieldCell: OZLFormFieldCell {
    let switchControl = UISwitch()
    let titleLabel = UILabel()
    var currentValue = false

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        self.switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), forControlEvents: .ValueChanged)
    }

    override func applyFormField(field: OZLFormField) {
        super.applyFormField(field)

        guard let field = field as? OZLSwitchFormField else {
            assertionFailure("Somehow received the wrong type of field")
            return
        }

        self.titleLabel.text = field.placeholder
        self.switchControl.on = field.currentValue
        self.currentValue = field.currentValue
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.switchControl.onTintColor = self.tintColor

        if self.switchControl.superview == nil {
            self.contentView.addSubview(self.switchControl)
            self.contentView.addSubview(self.titleLabel)
        }

        self.switchControl.sizeToFit()
        self.switchControl.frame = CGRectMake(self.contentView.frame.size.width - self.contentPadding - self.switchControl.frame.size.width,
                                              (self.contentView.frame.size.height - self.switchControl.frame.size.height) / 2.0,
                                              self.switchControl.frame.size.width,
                                              self.switchControl.frame.size.height)

        self.titleLabel.sizeToFit()
        self.titleLabel.frame = CGRectMake(self.contentPadding,
                                           (self.contentView.frame.size.height - self.titleLabel.frame.size.height) / 2.0,
                                           self.titleLabel.frame.size.width,
                                           self.titleLabel.frame.size.height)
    }

    func switchValueChanged(sender: UISwitch) {
        if sender.on != self.currentValue {
            self.delegate?.formFieldCell(self, valueChangedFrom: self.currentValue, toValue: sender.on, atKeyPath: self.keyPath, userInfo: self.userInfo)
            self.currentValue = sender.on
        }
    }
}
