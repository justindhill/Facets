//
//  OZLEnumerationFormField.swift
//  Facets
//
//  Created by Justin Hill on 3/16/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import JVFloatLabeledTextField

@objc protocol OZLEnumerationFormFieldValue: class {
    func stringValue() -> String
}

class OZLEnumerationFormField: OZLFormField {

    var possibleValues: [AnyObject]?
    var currentValue: String?

    init(keyPath: String, placeholder: String, currentValue: String?, possibleRealmValues: RLMCollection) {
        super.init(keyPath: keyPath, placeholder: placeholder)

        self.currentValue = currentValue

        if possibleRealmValues.count > 0 {
            var values = [OZLEnumerationFormFieldValue]()

            for index in 0..<possibleRealmValues.count {
                if let value = possibleRealmValues[index] as? OZLEnumerationFormFieldValue {
                    values.append(value)
                } else {
                    fatalError("Passed an RLMArray whose object type doesn't conform to OZLEnumerationFormFieldValue")
                }
            }

            self.possibleValues = values
        }
        
        self.setup()
    }

    init(keyPath: String, placeholder: String, currentValue: String?, possibleValues: [OZLEnumerationFormFieldValue]) {
        super.init(keyPath: keyPath, placeholder: placeholder)

        self.currentValue = currentValue

        // Boooo, this sucks.
        self.possibleValues = possibleValues.map { $0 as AnyObject }

        self.setup()
    }

    init(keyPath: String, placeholder: String, currentValue: String?, possibleStringValues: [String]) {
        super.init(keyPath: keyPath, placeholder: placeholder)

        self.currentValue = currentValue
        self.possibleValues = possibleStringValues as [AnyObject]?

        self.setup()
    }

    func setup() {
        self.fieldHeight = 48.0
        self.cellClass = OZLEnumerationFormFieldCell.self
    }
}

class OZLEnumerationFormFieldCell: OZLFormFieldCell, UITextFieldDelegate {

    var textField: JVFloatLabeledTextField = JVFloatLabeledTextField()
    var possibleValues: [AnyObject]?

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.textField.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.textField.delegate = self
    }

    override func applyFormField(_ field: OZLFormField) {
        super.applyFormField(field)

        guard let field = field as? OZLEnumerationFormField else {
            assertionFailure("Somehow got passed the wrong field type")
            return
        }

        self.textField.placeholder = field.placeholder
        self.textField.text = field.currentValue
        self.possibleValues = field.possibleValues
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.textField.superview == nil {
            self.contentView.addSubview(self.textField)
        }

        self.textField.frame = self.contentView.bounds
        self.textField.frame.origin.x = self.layoutMargins.left
        self.textField.frame.size.width -= (self.layoutMargins.left + self.layoutMargins.right)

        self.textField.floatingLabelYPadding = 7.0
        self.textField.floatingLabelTextColor = self.tintColor

        self.textField.layoutSubviews()
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        var closestVC = self.next

        while !(closestVC is UIViewController) && closestVC != nil {
            closestVC = closestVC?.next
        }

        weak var weakSelf = self

        if let closestVC = closestVC as? UIViewController{
            let sheet = UIAlertController(title: self.textField.placeholder, message: nil, preferredStyle: .actionSheet)

            for val in self.possibleValues ?? [] {
                if val is String {
                    let val = val as! String
                    sheet.addAction(UIAlertAction(title: val, style: .default, handler: { (action) in
                        if let weakSelf = weakSelf, weakSelf.textField.text != val {
                            weakSelf.delegate?.formFieldCell(weakSelf, valueChangedFrom: weakSelf.textField.text as AnyObject?, toValue: val as AnyObject?, atKeyPath: weakSelf.keyPath, userInfo: weakSelf.userInfo)
                        }

                        weakSelf?.textField.text = val
                    }))
                } else if val is OZLEnumerationFormFieldValue {
                    let val = val as! OZLEnumerationFormFieldValue

                    sheet.addAction(UIAlertAction(title: val.stringValue(), style: .default, handler: { (action) in
                        if let weakSelf = weakSelf, weakSelf.textField.text != val.stringValue() {
                            weakSelf.delegate?.formFieldCell(weakSelf, valueChangedFrom: nil, toValue: val, atKeyPath: weakSelf.keyPath, userInfo: weakSelf.userInfo)
                        }

                        weakSelf?.textField.text = val.stringValue()
                    }))
                }
            }

            sheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

            if self.delegate?.formFieldCellWillBeginEditing(self, firstResponder: self) ?? true {
                closestVC.present(sheet, animated: true, completion: nil)
            }
        }

        return false
    }
}
