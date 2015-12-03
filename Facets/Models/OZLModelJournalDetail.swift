//
//  OZLModelJournalDetail.swift
//  Facets
//
//  Created by Justin Hill on 11/28/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

@objc enum OZLModelJournalDetailType: Int {
    case Unknown
    case Attribute
    case CustomField
}

@objc class OZLModelJournalDetail: NSObject {
    private(set) var type: OZLModelJournalDetailType? = nil
    private(set) var oldValue: String? = nil
    private(set) var newValue: String? = nil
    
    private(set) var name: String? = nil
    
    private lazy var customField: OZLModelCustomField? = {
        if let id = self.name {
            if let intId = Int(id) {
                return OZLModelCustomField(forPrimaryKey: intId)
            }
        }
        
        return nil
    }()
    
    var displayName: String? {
        get {
            if self.type == .CustomField, let customField = self.customField {
                return customField.name
            } else if self.type == .Attribute, let name = self.name {
                return self.displayNameForAttributeName(name)
            }
            
            return self.name
        }
    }
    
    var displayOldValue: String? {
        get {
            if let oldValue = self.oldValue {
                return self.displayValueForAttributeValue(oldValue)
            }
            
            return self.oldValue
        }
    }
    
    var displayNewValue: String? {
        get {
            if let newValue = self.newValue {
                return displayValueForAttributeValue(newValue)
            }
            
            return self.newValue
        }
    }
    
    init(attributes: Dictionary<String, AnyObject>) {
        if let type = attributes["property"] as? String {
            if type == "attr" {
                self.type = .Attribute
            } else if type == "cf" {
                self.type = .CustomField
            } else {
                self.type = .Unknown
            }
        }
        
        self.name = attributes["name"] as? String
        
        if let oldValue = attributes["old_value"] as? String {
            if !oldValue.isEmpty {
                self.oldValue = oldValue
            }
        }
        
        if let newValue = attributes["new_value"] as? String {
            if !newValue.isEmpty {
                self.newValue = newValue
            }
        }
    }
    
    private func displayNameForAttributeName(attributeName: String) -> String {
        if attributeName == "project_id" {
            return "Project"
        } else if attributeName == "tracker_id" {
            return "Tracker"
        } else if attributeName == "fixed_version_id" {
            return "Target version"
        } else if attributeName == "status_id" {
            return "Status"
        } else if attributeName == "assigned_to_id" {
            return "Assignee"
        } else if attributeName == "category_id" {
            return "Category"
        } else if attributeName == "priority_id" {
            return "Priority"
        }
        
        return attributeName
    }
    
    private func displayValueForAttributeValue(attributeValue: String) -> String {
        if let attributeId = Int(attributeValue) {
            if self.type == .Attribute {
                if self.name == "project_id" {
                    return OZLModelProject(forPrimaryKey: attributeId)?.name ?? attributeValue
                } else if self.name == "tracker_id" {
                    return OZLModelTracker(forPrimaryKey: attributeId)?.name ?? attributeValue
                } else if self.name == "fixed_version_id" {
                    return OZLModelVersion(forPrimaryKey: attributeId)?.name ?? attributeValue
                } else if self.name == "status_id" {
                    return OZLModelIssueStatus(forPrimaryKey: attributeId)?.name ?? attributeValue
                } else if self.name == "assigned_to_id" {
                    return attributeValue
                } else if self.name == "category_id" {
                    return OZLModelIssueCategory(forPrimaryKey: attributeId)?.name ?? attributeValue
                } else if self.name == "priority_id" {
                    return OZLModelIssuePriority(forPrimaryKey: attributeId)?.name ?? attributeValue
                }
                
            } else if self.type == .CustomField {
                if let field = self.customField {
                    
                    // WARNING: Handle the rest of the custom field types! (just users, I think)
                    if field.type == .Version {
                        return OZLModelVersion(forPrimaryKey: attributeId)?.name ?? attributeValue
                    }
                }
            }
        }
        
        return attributeValue
    }
    
    override var description: String {
        get {
            return "<OZLModelJournalDetail: \(unsafeAddressOf(self)) type: \(self.type), name: \(self.name), oldValue: \(self.oldValue), newValue: \(self.newValue))"
        }
    }
}
