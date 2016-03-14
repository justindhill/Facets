//
//  OZLFormViewController.swift
//  Facets
//
//  Created by Justin Hill on 3/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLFormViewController: OZLTableViewController {

    var sections: [OZLFormSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.OZLVeryLightGrayColor()

        self.reloadData()
    }

    func reloadData() {
        self.sections = self.definitionsForFields()
        self.tableView.reloadData()
    }

    func definitionsForFields() -> [OZLFormSection] {
        assertionFailure("Must override definitionsForFields in a subclass")

        return []
    }

    // MARK: UITableViewDelegate/DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].fields.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let field = self.sections[indexPath.section].fields[indexPath.row]

        if let cellClass = field.cellClass as? OZLFormFieldCell.Type {
            cellClass.registerOnTableViewIfNeeded(tableView)

            let cell = cellClass.init(style: .Default, reuseIdentifier: String(cellClass.self))
            cell.applyFormField(field)
            cell.contentPadding = OZLContentPadding

            return cell
        }

        return UITableViewCell(style: .Default, reuseIdentifier: nil)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let field = self.sections[indexPath.section].fields[indexPath.row]

        if let cellClass = field.cellClass as? OZLFormFieldCell.Type {
            return cellClass.heightForWidth(tableView.frame.size.width)
        }

        return 0.0
    }
}
