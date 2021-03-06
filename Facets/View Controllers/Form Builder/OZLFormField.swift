//
//  OZLFormField.swift
//  Facets
//
//  Created by Justin Hill on 3/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

protocol OZLFormFieldDelegate: AnyObject {
    func formFieldCell(_ formCell: OZLFormFieldCell, valueChangedFrom fromValue: AnyObject?, toValue: AnyObject?, atKeyPath: String, userInfo: [String: AnyObject])
    func formFieldCellWillBeginEditing(_ formCell: OZLFormFieldCell, firstResponder: UIResponder?) -> Bool
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

    func applyFormField(_ field: OZLFormField) {
        self.keyPath = field.keyPath
        self.userInfo = field.userInfo
    }

    class func registerOnTableViewIfNeeded(_ tableView: UITableView) {
        tableView.register(OZLFormFieldCell.self, forCellReuseIdentifier: String(describing: OZLFormFieldCell.self))
    }
}
