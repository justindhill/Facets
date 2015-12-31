//
//  OZLSortAndFilterViewController.swift
//  Facets
//
//  Created by Justin Hill on 12/31/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

@objc enum OZLSortOrder: Int {
    case Ascending
    case Descending
}

@objc class OZLSortAndFilterField: NSObject {
    var displayName: String
    var serverName: String
    var value: String?
    
    init(displayName: String, serverName: String, value: String?) {
        self.displayName = displayName
        self.serverName = serverName
        self.value = value
        
        super.init()
    }
    
    convenience init(displayName: String, serverName: String) {
        self.init(displayName: displayName, serverName: serverName, value: nil)
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? OZLSortAndFilterField {
            return (object.displayName == self.displayName &&
                    object.serverName == self.serverName &&
                    (object.value == self.value || (object.value == nil && self.value == nil)))
        }
        
        return false
    }
}

@objc class OZLSortAndFilterOptions: NSObject, NSCopying {
    var sortOrder: OZLSortOrder = .Descending
    var sortField: OZLSortAndFilterField = OZLSortAndFilterField(displayName: "Last Updated", serverName: "updated_on")
    
    func requestParameters() -> Dictionary<String, String> {
        var params: Dictionary<String, String> = Dictionary<String, String>()
        var sortValue = self.sortField.serverName
        
        if (self.sortOrder == .Descending) {
            sortValue += ":desc"
        }
        
        params["sort"] = sortValue
        
        return params
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object {
            return (object.sortOrder == self.sortOrder && object.sortField.isEqual(self.sortField))
        }
        
        return false
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let options = OZLSortAndFilterOptions()
        options.sortOrder = self.sortOrder
        options.sortField = self.sortField
        
        return options
    }
}

@objc protocol OZLSortAndFilterViewControllerDelegate {
    func sortAndFilter(sortAndFilter: OZLSortAndFilterViewController, shouldDismissWithNewOptions newOptions: OZLSortAndFilterOptions?)
}

class OZLSortAndFilterViewController: UITableViewController {
    
    weak var delegate: OZLSortAndFilterViewControllerDelegate?
    
    // WARNING: This is a weird, hacky way of doing a copy property in Swift. Maybe there's a better way, but I'm not convinced.
    var internalOptions: OZLSortAndFilterOptions = OZLSortAndFilterOptions()
    var options: OZLSortAndFilterOptions {
        set(value) {
            self.internalOptions = value.copy() as! OZLSortAndFilterOptions
        }
        
        get {
            return self.internalOptions
        }
    }
    
    private let SortFieldSection = 0;
    private let SortOrderSection = 1
    private let FiltersSection = 2
    
    private static let defaultFields = [
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
    
    private let TextReuseIdentifier = "TextReuseIdentifier"
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sort and Filter"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAction")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveAction")
    }
    
    // MARK: Button actions
    func cancelAction() {
        self.delegate?.sortAndFilter(self, shouldDismissWithNewOptions: nil)
    }
    
    func saveAction() {
        self.delegate?.sortAndFilter(self, shouldDismissWithNewOptions: self.options)
    }

    // MARK: - UITableViewDelegate/DataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SortFieldSection {
            return 1
        } else if section == SortOrderSection {
            return 2
        } else if section == FiltersSection {
            return 1
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(TextReuseIdentifier)
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: TextReuseIdentifier)
        }
        
        cell?.textLabel?.textColor = UIColor.blackColor()
        
        if indexPath.section == SortFieldSection {
            cell?.textLabel?.text = self.options.sortField.displayName
        } else if indexPath.section == SortOrderSection {
            if (indexPath.row == 0) {
                cell?.textLabel?.text = "Ascending"
                cell?.accessoryType = self.options.sortOrder == .Ascending ? .Checkmark : .None
            } else if (indexPath.row == 1) {
                cell?.textLabel?.text = "Descending"
                cell?.accessoryType = self.options.sortOrder == .Descending ? .Checkmark : .None
            }
            
        } else if indexPath.section == FiltersSection {
            cell?.textLabel?.textColor = self.view.tintColor
            cell?.textLabel?.text = "Add a filter"
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SortOrderSection {
            return "Sort Order"
        } else if section == SortFieldSection {
            return "Sort Field"
        } else if section == FiltersSection {
            return "Filters"
        }
        
        return nil
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == SortOrderSection {
            if indexPath.row == 0 {
                self.options.sortOrder = .Ascending
            } else {
                self.options.sortOrder = .Descending
            }
            
            let ascendingCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: SortOrderSection))
            ascendingCell?.accessoryType = self.options.sortOrder == .Ascending ? .Checkmark : .None
            
            let descendingCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: SortOrderSection))
            descendingCell?.accessoryType = self.options.sortOrder == .Descending ? .Checkmark : .None
        }
    }
}
