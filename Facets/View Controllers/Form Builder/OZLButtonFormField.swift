//
//  OZLButtonFormField.swift
//  Facets
//
//  Created by Justin Hill on 3/17/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

class OZLButtonFormField: OZLFormField {

    var title: String
    weak var target: AnyObject?
    var action: Selector
    var titleColor: UIColor?
    var accessoryType: UITableViewCellAccessoryType

    init(keyPath: String, title: String, titleColor: UIColor? = nil, highlightBackgroundColor: UIColor? = nil,
         accessoryType: UITableViewCellAccessoryType = .None, target: AnyObject, action: Selector) {

        self.title = title
        self.titleColor = titleColor
        self.target = target
        self.action = action
        self.accessoryType = accessoryType

        super.init(keyPath: keyPath, placeholder: title)

        self.fieldHeight = 44.0
        self.cellClass = OZLButtonFormFieldCell.self
    }
}

class OZLButtonFormFieldCell: OZLFormFieldCell {
    let buttonControl = UIButton()
    var currentValue = false
    var useTintColor = true
    var highlightBackgroundColor: UIColor?

    var buttonTarget: AnyObject?
    var buttonAction: Selector?

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        self.buttonControl.addTarget(self, action: #selector(buttonActionInternal(_:)), forControlEvents: .TouchUpInside)
    }

    func buttonActionInternal(sender: UIButton?) {
        if let target = self.buttonTarget, let action = self.buttonAction {
            target.performSelector(action, withObject: self.keyPath)
        }
    }

    override func applyFormField(field: OZLFormField) {
        super.applyFormField(field)

        guard let field = field as? OZLButtonFormField else {
            assertionFailure("Somehow received the wrong type of field")
            return
        }

        if let titleColor = field.titleColor {
            self.useTintColor = false
            self.setTitleColor(titleColor)
        } else {
            self.useTintColor = true
            self.setTitleColor(self.tintColor)
        }

        self.buttonTarget = field.target
        self.buttonAction = field.action

        self.accessoryType = field.accessoryType
        self.buttonControl.titleLabel?.font = UIFont.systemFontOfSize(17.0)
        self.buttonControl.contentHorizontalAlignment = .Left
        self.buttonControl.setTitle(field.title, forState: .Normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.buttonControl.superview == nil {
            self.contentView.addSubview(self.buttonControl)
        }

        self.buttonControl.frame = self.contentView.bounds
        self.buttonControl.titleEdgeInsets = UIEdgeInsetsMake(0, self.contentPadding, 0, self.contentPadding)
    }

    private func setTitleColor(titleColor: UIColor) {
        self.buttonControl.setTitleColor(titleColor, forState: .Normal)
        self.buttonControl.setTitleColor(titleColor.colorWithAlphaComponent(0.75), forState: .Highlighted)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        if self.useTintColor {
            self.setTitleColor(self.tintColor)
        }
    }
}
