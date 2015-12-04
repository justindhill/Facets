//
//  OZLModelMembership.swift
//  Facets
//
//  Created by Justin Hill on 12/3/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

// I really only care about the user here, so this model will be very incomplete
@objc class OZLModelMembership: NSObject {
    var user: OZLModelUser? = nil
    
    init(attributeDictionary: Dictionary<String, AnyObject>) {
        super.init()
        self.applyAttributeDictionary(attributeDictionary)
    }
    
    func applyAttributeDictionary(attributes: Dictionary<String, AnyObject>) {
        if let userDict = attributes["user"] as? Dictionary<String, AnyObject> {
            self.user = OZLModelUser(attributeDictionary: userDict)
        }
    }
}
