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
    
    private(set) var name: String? = nil {
        didSet {
            // this is probably super paranoid, 'cause these are externally immutable
            self.cachedDisplayName = nil
        }
    }
    
    private var cachedDisplayName: String?
    var displayName: String? {
        get {
            if self.cachedDisplayName != nil {
                return self.cachedDisplayName
            } else {
                if self.type == .CustomField, let name = self.name {
                    if let id = Int(name) {
                        if let customField = OZLModelCustomField(forPrimaryKey: id) {
                            self.cachedDisplayName = customField.name
                            return customField.name
                        }
                    }
                } else if self.type == .Attribute, let name = self.name {
                    return OZLModelIssue.displayNameForAttributeName(name)
                }
                
                return self.name
            }
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
    
    override var description: String {
        get {
            return "<OZLModelJournalDetail: \(unsafeAddressOf(self)) type: \(self.type), name: \(self.name), oldValue: \(self.oldValue), newValue: \(self.newValue))"
        }
    }
}
