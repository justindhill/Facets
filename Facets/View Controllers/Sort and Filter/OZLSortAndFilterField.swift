//
//  OZLSortAndFilterField.swift
//  Facets
//
//  Created by Justin Hill on 1/1/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

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
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? OZLSortAndFilterField {
            return (object.displayName == self.displayName &&
                object.serverName == self.serverName &&
                (object.value == self.value || (object.value == nil && self.value == nil)))
        }
        
        return false
    }
}
