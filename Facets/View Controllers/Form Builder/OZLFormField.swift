//
//  OZLFormField.swift
//  Facets
//
//  Created by Justin Hill on 3/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

class OZLFormField: NSObject {
    var keyPath: String
    var placeholder: String
    var cellClass: AnyClass

    init(keyPath: String, placeholder: String) {
        self.keyPath = keyPath
        self.placeholder = placeholder
        self.cellClass = UITableViewCell.self

        super.init()
    }
}

class OZLFormFieldCell: UITableViewCell {
    var contentPadding: CGFloat = 0.0;

    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func applyFormField(field: OZLFormField) {
        assertionFailure("Must override this in a subclass.")
    }

    class func registerOnTableViewIfNeeded(tableView: UITableView) {
        tableView.registerClass(OZLFormFieldCell.self, forCellReuseIdentifier: String(OZLFormFieldCell.self))
    }

    class func heightForWidth(width: CGFloat) -> CGFloat {
        return 44.0
    }
}
