//
//  OZLFieldSelectorTableViewController.swift
//  Facets
//
//  Created by Justin Hill on 1/1/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLFieldSelectorViewController: UITableViewController {
    
    private let defaultFields = [
        ("Project", "project"),
        ("Tracker", "tracker"),
        ("Status", "status"),
        ("Priority", "priority"),
        ("Author", "author"),
        ("Category", "category"),
        ("Start Date", "start_date"),
        ("Due Date", "due_date"),
        ("Percent Done", "done_ratio"),
        ("Estimated Hours", "estimated_hours"),
        ("Creation Date", "created_on"),
        ("Last Updated", "last_updated")
    ]
    
    let DefaultFieldSection = 0
    let CustomFieldSection = 1
    var selectionChangeHandler: ((field: OZLSortAndFilterField) -> Void)?
    
    let TextReuseIdentifier = "TextReuseIdentifier"
    
    let customFields = OZLModelCustomField.allObjects()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Select a Field"
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:self.TextReuseIdentifier)
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == DefaultFieldSection {
            return self.defaultFields.count
        } else if section == CustomFieldSection {
            return Int(self.customFields.count)
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.TextReuseIdentifier, forIndexPath: indexPath)
        
        if indexPath.section == DefaultFieldSection {
            let (displayName, _) = self.defaultFields[indexPath.row]
            cell.textLabel?.text = displayName
        } else if indexPath.section == CustomFieldSection {
            let field = self.customFields[UInt(indexPath.row)]
            cell.textLabel?.text = field.name
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == DefaultFieldSection {
            let (displayName, serverName) = self.defaultFields[indexPath.row]
            self.selectionChangeHandler?(field: OZLSortAndFilterField(displayName: displayName, serverName: serverName))
            
        } else if indexPath.section == CustomFieldSection {
            guard let field = self.customFields[UInt(indexPath.row)] as? OZLModelCustomField else {
                return
            }
            
            if let fieldName = field.name {
                let serverName = "cf_" + String(field.fieldId)
                self.selectionChangeHandler?(field: OZLSortAndFilterField(displayName: fieldName, serverName: serverName))
            }
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}
