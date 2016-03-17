//
//  OZLEnumerationFormField.swift
//  Facets
//
//  Created by Justin Hill on 3/16/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

protocol OZLEnumerationFormFieldValue: class {
    func stringValue() -> String
}

class OZLEnumerationFormField: OZLFormField {

    var possibleValues: [AnyObject]!
    var currentValue: String?

    init(keyPath: String, placeholder: String, currentValue: String?, possibleValues: [OZLEnumerationFormFieldValue]) {
        super.init(keyPath: keyPath, placeholder: placeholder)

        self.currentValue = currentValue

        // Boooo, this sucks.
        self.possibleValues = possibleValues.map { $0 as AnyObject }

        self.setup()
    }

    init(keyPath: String, placeholder: String, currentValue: String?, possibleValues: [String]) {
        super.init(keyPath: keyPath, placeholder: placeholder)

        self.currentValue = currentValue
        self.possibleValues = possibleValues

        self.setup()
    }

    func setup() {
        self.fieldHeight = 48.0
        self.cellClass = OZLEnumerationFormFieldCell.self
    }
}

class OZLEnumerationFormFieldCell: OZLFormFieldCell, UITextFieldDelegate {

    var textField: JVFloatLabeledTextField = JVFloatLabeledTextField()
    var possibleValues: [AnyObject]!

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.textField.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.textField.delegate = self
    }

    override func applyFormField(field: OZLFormField) {
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
        self.textField.frame.origin.x = self.contentPadding
        self.textField.frame.size.width -= 2 * self.contentPadding

        self.textField.floatingLabelYPadding = 7.0
        self.textField.floatingLabelTextColor = self.tintColor

        self.textField.layoutSubviews()
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {

        var closestVC = self.nextResponder()

        while !(closestVC is UIViewController) && closestVC != nil {
            closestVC = closestVC?.nextResponder()
        }

        weak var weakSelf = self

        if let closestVC = closestVC as? UIViewController{
            let sheet = UIAlertController(title: self.textField.placeholder, message: nil, preferredStyle: .ActionSheet)

            for val in self.possibleValues {
                if val is String {
                    let val = val as! String
                    sheet.addAction(UIAlertAction(title: val, style: .Default, handler: { (action) in
                        if let weakSelf = weakSelf where weakSelf.textField.text != val {
                            weakSelf.delegate?.fieldValueChangedFrom(weakSelf.textField.text, toValue: val, atKeyPath: weakSelf.keyPath!)
                        }

                        weakSelf?.textField.text = val
                    }))
                } else if val is OZLEnumerationFormFieldValue {
                    let val = val as! OZLEnumerationFormFieldValue

                    sheet.addAction(UIAlertAction(title: val.stringValue(), style: .Default, handler: { (action) in
                        if let weakSelf = weakSelf where weakSelf.textField.text != val.stringValue() {
                            weakSelf.delegate?.fieldValueChangedFrom(nil, toValue: val, atKeyPath: self.keyPath!)
                        }

                        weakSelf?.textField.text = val.stringValue()
                    }))
                }
            }

            sheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))

            closestVC.presentViewController(sheet, animated: true, completion: nil)
        }

        return false
    }
}
