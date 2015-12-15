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
    case Attachment
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
                return OZLModelIssue.displayNameForAttributeName(name)
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
            } else if type == "attachment" {
                self.type = .Attachment
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
    
    private func displayValueForAttributeValue(attributeValue: String) -> String {
        if let attributeId = Int(attributeValue) {
            if self.type == .Attribute {
                return OZLModelIssue.displayValueForAttributeName(self.name, attributeId: attributeId) ?? attributeValue
                
            } else if self.type == .CustomField {
                if let field = self.customField {
                    OZLModelCustomField.displayValueForCustomFieldType(field.type, attributeId: attributeId, attributeValue: attributeValue)
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
