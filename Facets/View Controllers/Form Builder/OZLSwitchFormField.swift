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
        self.switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }

    override func applyFormField(_ field: OZLFormField) {
        super.applyFormField(field)

        guard let field = field as? OZLSwitchFormField else {
            assertionFailure("Somehow received the wrong type of field")
            return
        }

        self.titleLabel.text = field.placeholder
        self.switchControl.isOn = field.currentValue
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
        self.switchControl.frame = CGRect(x: self.contentView.frame.size.width - self.layoutMargins.right - self.switchControl.frame.size.width,
                                          y: (self.contentView.frame.size.height - self.switchControl.frame.size.height) / 2.0,
                                          width: self.switchControl.frame.size.width,
                                          height: self.switchControl.frame.size.height)

        self.titleLabel.sizeToFit()
        self.titleLabel.frame = CGRect(x: self.layoutMargins.left,
                                       y: (self.contentView.frame.size.height - self.titleLabel.frame.size.height) / 2.0,
                                       width: self.titleLabel.frame.size.width,
                                       height: self.titleLabel.frame.size.height)
    }

    @objc func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn != self.currentValue {
            self.delegate?.formFieldCell(self, valueChangedFrom: self.currentValue as AnyObject?, toValue: sender.isOn as AnyObject?, atKeyPath: self.keyPath, userInfo: self.userInfo)
            self.currentValue = sender.isOn
        }
    }
}
