//
//  OZLModelJournalDetail.swift
//  Facets
//
//  Created by Justin Hill on 11/28/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

@objc enum OZLModelJournalDetailType: Int {
    case unknown
    case attribute
    case customField
    case attachment
}

@objc class OZLModelJournalDetail: NSObject {
    var type: OZLModelJournalDetailType = .unknown
    var oldValue: String? = nil
    var newValue: String? = nil
    
    var name: String? = nil
    
    fileprivate lazy var customField: OZLModelCustomField? = {
        if let id = self.name {
            if let intId = Int(id) {
                return OZLModelCustomField(forPrimaryKey: intId)
            }
        }
        
        return nil
    }()
    
    var displayName: String? {
        get {
            if self.type == .customField, let customField = self.customField {
                return customField.name
            } else if self.type == .attribute, let name = self.name {
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
    
    override init() {
        super.init()
    }
    
    convenience init(attributes: Dictionary<String, AnyObject>) {
        self.init()
        
        if let type = attributes["property"] as? String {
            if type == "attr" {
                self.type = .attribute
            } else if type == "cf" {
                self.type = .customField
            } else if type == "attachment" {
                self.type = .attachment
            } else {
                self.type = .unknown
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
    
    fileprivate func displayValueForAttributeValue(_ attributeValue: String) -> String {
        if let attributeId = Int(attributeValue) {
            if self.type == .attribute {
                return OZLModelIssue.displayValueForAttributeName(self.name, attributeId: attributeId) ?? attributeValue
                
            } else if self.type == .customField {
                if let field = self.customField {
                    return OZLModelCustomField.displayValue(for: field.type, attributeId: attributeId, attributeValue: attributeValue)
                }
            }
        }
        
        return attributeValue
    }
    
    override var description: String {
        get {
            return "<OZLModelJournalDetail: \(Unmanaged.passUnretained(self).toOpaque()) type: \(self.type), name: \(String(describing: self.name)), oldValue: \(String(describing: self.oldValue)), newValue: \(String(describing: self.newValue)))"
        }
    }
}
