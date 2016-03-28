//
//  OZLFormField.swift
//  Facets
//
//  Created by Justin Hill on 3/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

protocol OZLFormFieldDelegate {
    func formFieldCell(formCell: OZLFormFieldCell, valueChangedFrom fromValue: AnyObject?, toValue: AnyObject?, atKeyPath: String, userInfo: [String: AnyObject])
    func formFieldCellWillBeginEditing(formCell: OZLFormFieldCell, firstResponder: UIResponder?)
}

class OZLFormField: NSObject {
    var keyPath: String
    var placeholder: String
    var cellClass: AnyClass
    var fieldHeight: CGFloat = 0.0

    var userInfo: [String: AnyObject] = Dictionary()

    init(keyPath: String, placeholder: String) {
        self.keyPath = keyPath
        self.placeholder = placeholder
        self.cellClass = UITableViewCell.self

        super.init()
    }
}

class OZLFormFieldCell: UITableViewCell {
    var contentPadding: CGFloat = 0.0;
    var keyPath: String!
    var delegate: OZLFormFieldDelegate?
    var userInfo: [String: AnyObject]!

    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func applyFormField(field: OZLFormField) {
        self.keyPath = field.keyPath
        self.userInfo = field.userInfo
    }

    class func registerOnTableViewIfNeeded(tableView: UITableView) {
        tableView.registerClass(OZLFormFieldCell.self, forCellReuseIdentifier: String(OZLFormFieldCell.self))
    }

    class func heightForWidth(width: CGFloat) -> CGFloat {
        return 44.0
    }
}
