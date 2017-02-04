//
//  OZLTextAreaFormField.swift
//  Facets
//
//  Created by Justin Hill on 3/15/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import JVFloatLabeledTextField

class OZLTextViewFormField: OZLFormField {
    var currentValue: String?

    init(keyPath: String, placeholder: String, currentValue: String? = nil) {
        self.currentValue = currentValue

        super.init(keyPath: keyPath, placeholder: placeholder)

        self.fieldHeight = 150.0
        self.cellClass = OZLTextViewFormFieldCell.self
    }
}

class OZLTextViewFormFieldCell: OZLFormFieldCell, UITextViewDelegate {
    var textView = JVFloatLabeledTextView()
    fileprivate var valueBeforeEditing: String?

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.textView.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.textView.delegate = self
    }

    override func applyFormField(_ field: OZLFormField) {
        super.applyFormField(field)
        
        guard let field = field as? OZLTextViewFormField else {
            assertionFailure("Somehow got passed the wrong type of field")
            return
        }

        self.textView.placeholder = field.placeholder
        self.textView.text = field.currentValue
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.textView.superview == nil {
            self.contentView.addSubview(self.textView)
        }

        self.textView.frame = self.contentView.bounds
        self.textView.frame.origin.x += self.layoutMargins.left
        self.textView.frame.size.width -= (self.layoutMargins.left + self.layoutMargins.right)
        self.textView.floatingLabelYPadding = 8
        self.textView.layoutSubviews()
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if self.delegate?.formFieldCellWillBeginEditing(self, firstResponder: self) ?? true {
            self.valueBeforeEditing = textView.text
            return true
        }
        
        return false
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text != self.valueBeforeEditing {
            let oldValue = self.valueBeforeEditing != "" ? self.valueBeforeEditing : nil
            let newValue = textView.text != "" ? textView.text : nil

            self.delegate?.formFieldCell(self, valueChangedFrom: oldValue as AnyObject?, toValue: newValue as AnyObject?, atKeyPath: self.keyPath, userInfo: self.userInfo)
        }
        
        return true
    }
}
