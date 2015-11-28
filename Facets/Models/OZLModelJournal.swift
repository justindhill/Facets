//
//  OZLModelJournal.swift
//  Facets
//
//  Created by Justin Hill on 11/26/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

class OZLModelJournal: NSObject {
    
    private(set) var author: OZLModelUser? = nil
    private(set) var notes: String? = nil
    private(set) var journalId: Int? = nil
    private(set) var creationDate: NSDate? = nil
    
    init(attributes: Dictionary<String, AnyObject>) {
        if let authorDict = attributes["user"] as? Dictionary<String, AnyObject> {
            self.author = OZLModelUser(dictionary: authorDict)
        }
        
        self.notes = attributes["notes"] as? String
        self.journalId = attributes["id"] as? Int
        
        if let dateString = attributes["created_on"] as? String {
            self.creationDate = NSDate(ISO8601String: dateString)
        }
        
        super.init()
    }
}
