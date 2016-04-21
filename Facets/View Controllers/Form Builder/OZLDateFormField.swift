//
//  OZLDateFormField.swift
//  Facets
//
//  Created by Justin Hill on 4/19/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import JVFloatLabeledTextField

class OZLDateFormField: OZLFormField {

    var currentValue: NSDate?

    init(keyPath: String, placeholder: String, currentValue: NSDate? = nil) {
        super.init(keyPath: keyPath, placeholder: placeholder)
        self.currentValue = currentValue
        self.setup()
    }

    func setup() {
        self.fieldHeight = 48.0
        self.cellClass = OZLDateFormFieldCell.self
    }
}

class OZLDateFormFieldCell: OZLFormFieldCell, UITextFieldDelegate {

    static var dateFormatter = NSDateFormatter()

    override var inputView: UIView? {
        get {
            return self.datePicker
        }
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    let datePicker = UIDatePicker()
    var textField: JVFloatLabeledTextField = JVFloatLabeledTextField()
    var possibleValues: [AnyObject]!

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.textField.delegate = self
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.textField.delegate = self
        self.setup()
    }

    private var setupOnceToken = dispatch_once_t()
    func setup() {
        dispatch_once(&setupOnceToken) {
            OZLDateFormFieldCell.dateFormatter.dateFormat = "M/d/yyyy"
        }

        self.datePicker.backgroundColor = UIColor.whiteColor()
        self.datePicker.datePickerMode = .Date
        self.datePicker.addTarget(self, action: #selector(dateChanged), forControlEvents: .ValueChanged)

        self.textField.userInteractionEnabled = false
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }

    override func applyFormField(field: OZLFormField) {
        super.applyFormField(field)

        guard let field = field as? OZLDateFormField else {
            assertionFailure("Somehow got passed the wrong field type")
            return
        }

        self.textField.placeholder = field.placeholder
        if let currentValue = field.currentValue {
            self.textField.text = OZLDateFormFieldCell.dateFormatter.stringFromDate(currentValue)
        }
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

    func tapAction() {
        self.delegate?.formFieldCellWillBeginEditing(self, firstResponder: self)
        self.becomeFirstResponder()
    }

    func dateChanged() {
        self.textField.text = OZLDateFormFieldCell.dateFormatter.stringFromDate(self.datePicker.date)
        self.delegate?.formFieldCell(self, valueChangedFrom: nil, toValue: self.datePicker.date, atKeyPath: self.keyPath, userInfo: [:])
    }
}
