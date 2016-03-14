//
//  OZLTextFormField.swift
//  Facets
//
//  Created by Justin Hill on 3/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

class OZLTextFormField: OZLFormField {

    var currentValue: String?

    init(keyPath: String, placeholder: String, currentValue: String? = nil) {
        self.currentValue = currentValue

        super.init(keyPath: keyPath, placeholder: placeholder)

        self.cellClass = OZLTextFormFieldCell.self
    }

}

class OZLTextFormFieldCell: OZLFormFieldCell {

    var textField = JVFloatLabeledTextField()

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func applyFormField(field: OZLFormField) {
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
        self.textField.frame.origin.x = self.contentPadding
        self.textField.frame.size.width -= (self.contentPadding * 2)
        self.textField.floatingLabelYPadding = 7.0
        self.textField.floatingLabelTextColor = self.tintColor

        self.textField.layoutSubviews()
    }

    override class func heightForWidth(width: CGFloat) -> CGFloat {
        return 48.0
    }
}
