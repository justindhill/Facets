//
//  OZLSortAndFilterViewController.swift
//  Facets
//
//  Created by Justin Hill on 12/31/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

@objc enum OZLSortOrder: Int {
    case ascending
    case descending
}

@objc class OZLSortAndFilterOptions: NSObject, NSCopying {
    var sortOrder: OZLSortOrder = .descending
    var sortField: OZLSortAndFilterField = OZLSortAndFilterField(displayName: "Last Updated", serverName: "updated_on")
    
    func requestParameters() -> Dictionary<String, String> {
        var params: Dictionary<String, String> = Dictionary<String, String>()
        var sortValue = self.sortField.serverName
        
        if (self.sortOrder == .descending) {
            sortValue += ":desc"
        }
        
        params["sort"] = sortValue
        
        return params
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object {
            return ((object as AnyObject).sortOrder == self.sortOrder && (object as AnyObject).sortField.isEqual(self.sortField))
        }
        
        return false
    }
    
    func copy(with zone: NSZone?) -> Any {
        let options = OZLSortAndFilterOptions()
        options.sortOrder = self.sortOrder
        options.sortField = self.sortField
        
        return options
    }
}

@objc protocol OZLSortAndFilterViewControllerDelegate {
    func sortAndFilter(_ sortAndFilter: OZLSortAndFilterViewController, shouldDismissWithNewOptions newOptions: OZLSortAndFilterOptions?)
}

class OZLSortAndFilterViewController: UITableViewController {
    
    weak var delegate: OZLSortAndFilterViewControllerDelegate?
    
    @NSCopying var options = OZLSortAndFilterOptions()
    
    fileprivate let SortFieldSection = 0;
    fileprivate let SortOrderSection = 1
    fileprivate let FiltersSection = 2
    
    fileprivate let TextReuseIdentifier = "TextReuseIdentifier"
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sort and Filter"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(OZLSortAndFilterViewController.cancelAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(OZLSortAndFilterViewController.saveAction))
    }
    
    // MARK: Button actions
    func cancelAction() {
        self.delegate?.sortAndFilter(self, shouldDismissWithNewOptions: nil)
    }
    
    func saveAction() {
        self.delegate?.sortAndFilter(self, shouldDismissWithNewOptions: self.options)
    }

    // MARK: - UITableViewDelegate/DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SortFieldSection {
            return 1
        } else if section == SortOrderSection {
            return 2
        } else if section == FiltersSection {
            return 1
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: TextReuseIdentifier)
        
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: TextReuseIdentifier)
        }
        
        cell?.textLabel?.textColor = UIColor.black
        
        if indexPath.section == SortFieldSection {
            cell?.textLabel?.text = self.options.sortField.displayName
            cell?.accessoryType = .disclosureIndicator
        } else if indexPath.section == SortOrderSection {
            if (indexPath.row == 0) {
                cell?.textLabel?.text = "Ascending"
                cell?.accessoryType = self.options.sortOrder == .ascending ? .checkmark : .none
            } else if (indexPath.row == 1) {
                cell?.textLabel?.text = "Descending"
                cell?.accessoryType = self.options.sortOrder == .descending ? .checkmark : .none
            }
            
        } else if indexPath.section == FiltersSection {
            cell?.accessoryType = .none
            cell?.textLabel?.textColor = self.view.tintColor
            cell?.textLabel?.text = "Add a filter"
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SortOrderSection {
            return "Sort Order"
        } else if section == SortFieldSection {
            return "Sort Field"
        } else if section == FiltersSection {
            return "Filters"
        }
        
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == SortFieldSection {
            let fieldSelector = OZLFieldSelectorViewController()
            
            weak var weakSelf = self
            fieldSelector.selectionChangeHandler = { (field: OZLSortAndFilterField) -> Void in
                weakSelf?.options.sortField = field
                weakSelf?.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            }
            
            self.navigationController?.pushViewController(fieldSelector, animated: true)
            
        } else if indexPath.section == SortOrderSection {
            tableView.deselectRow(at: indexPath, animated: true)
            
            if indexPath.row == 0 {
                self.options.sortOrder = .ascending
            } else {
                self.options.sortOrder = .descending
            }
            
            let ascendingCell = tableView.cellForRow(at: IndexPath(row: 0, section: SortOrderSection))
            ascendingCell?.accessoryType = self.options.sortOrder == .ascending ? .checkmark : .none
            
            let descendingCell = tableView.cellForRow(at: IndexPath(row: 1, section: SortOrderSection))
            descendingCell?.accessoryType = self.options.sortOrder == .descending ? .checkmark : .none
        }
        
    }
}
