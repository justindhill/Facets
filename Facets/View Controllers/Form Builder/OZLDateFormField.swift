//
//  OZLDateFormField.swift
//  Facets
//
//  Created by Justin Hill on 4/19/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import JVFloatLabeledTextField

class OZLDateFormField: OZLFormField {

    var currentValue: Date?

    init(keyPath: String, placeholder: String, currentValue: Date? = nil) {
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

    static var dateFormatter = DateFormatter()

    override var inputView: UIView? {
        get {
            return self.datePicker
        }
    }

    override var canBecomeFirstResponder: Bool {
        get { return true }
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
    
    override var inputAccessoryView: UIView? {
        get {
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44.0))
            
            toolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(resignFirstResponder))
            ]
            
            return toolbar
        }
    }

    func setup() {
        OZLDateFormFieldCell.dateFormatter.dateFormat = "M/d/yyyy"

        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = .date
        self.datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        self.textField.isUserInteractionEnabled = false
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }

    override func applyFormField(_ field: OZLFormField) {
        super.applyFormField(field)

        guard let field = field as? OZLDateFormField else {
            assertionFailure("Somehow got passed the wrong field type")
            return
        }

        self.textField.placeholder = field.placeholder
        if let currentValue = field.currentValue {
            self.textField.text = OZLDateFormFieldCell.dateFormatter.string(from: currentValue as Date)
        }
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

    @objc func tapAction() {
        if self.delegate?.formFieldCellWillBeginEditing(self, firstResponder: self) ?? true {
            self.becomeFirstResponder()
        }
    }

    @objc func dateChanged() {
        self.textField.text = OZLDateFormFieldCell.dateFormatter.string(from: self.datePicker.date)
        self.delegate?.formFieldCell(self, valueChangedFrom: nil, toValue: self.datePicker.date as AnyObject?, atKeyPath: self.keyPath, userInfo: self.userInfo)
    }
}
