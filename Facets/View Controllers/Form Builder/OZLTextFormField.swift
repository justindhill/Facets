//
//  OZLTextFormField.swift
//  Facets
//
//  Created by Justin Hill on 3/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import JVFloatLabeledTextField

class OZLTextFormField: OZLFormField {
    var currentValue: String?

    init(keyPath: String, placeholder: String, currentValue: String? = nil) {
        self.currentValue = currentValue

        super.init(keyPath: keyPath, placeholder: placeholder)

        self.fieldHeight = 48.0
        self.cellClass = OZLTextFormFieldCell.self
    }
}

class OZLTextFormFieldCell: OZLFormFieldCell, UITextFieldDelegate {

    var textField = JVFloatLabeledTextField()
    fileprivate var valueBeforeEditing: String?

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        self.textField.delegate = self
        self.textField.returnKeyType = .done
    }

    override func applyFormField(_ field: OZLFormField) {
        super.applyFormField(field)
        
        guard let field = field as? OZLTextFormField else {
            assertionFailure("Somehow got passed the wrong type of field")
            return
        }

        self.textField.placeholder = field.placeholder
        self.textField.text = field.currentValue
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if (self.textField.superview == nil) {
            self.contentView.addSubview(self.textField)
        }

        self.textField.frame = self.contentView.bounds
        self.textField.frame.origin.x = self.layoutMargins.left
        self.textField.frame.size.width -= (self.layoutMargins.left + self.layoutMargins.right)
        self.textField.floatingLabelYPadding = 7.0
        self.textField.floatingLabelTextColor = self.tintColor

        self.textField.layoutSubviews()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return false
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.delegate?.formFieldCellWillBeginEditing(self, firstResponder: self) ?? true {
            self.valueBeforeEditing = textField.text
            return true
        }
        
        return false
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != self.valueBeforeEditing {
            let oldValue = self.valueBeforeEditing != "" ? self.valueBeforeEditing : nil
            let newValue = textField.text != "" ? textField.text : nil

            self.delegate?.formFieldCell(self, valueChangedFrom: oldValue as AnyObject?, toValue: newValue as AnyObject?, atKeyPath: self.keyPath, userInfo: self.userInfo)
        }

        return true
    }
}
