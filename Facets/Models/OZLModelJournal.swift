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
    private(set) var details: Array<OZLModelJournalDetail> = []
    
    init(attributes: Dictionary<String, AnyObject>) {
        if let authorDict = attributes["user"] as? Dictionary<String, AnyObject> {
            self.author = OZLModelUser(dictionary: authorDict)
        }
        
        self.notes = attributes["notes"] as? String
        self.journalId = attributes["id"] as? Int
        
        if let dateString = attributes["created_on"] as? String {
            self.creationDate = NSDate(ISO8601String: dateString)
        }
        
        if let details = attributes["details"] as? Array<Dictionary<String, AnyObject>> {
            var detailModels: Array<OZLModelJournalDetail> = []
            for detailDict in details {
                detailModels.append(OZLModelJournalDetail(attributes: detailDict))
            }
            
            self.details = detailModels
        }
        
        super.init()
    }
    
    override var description: String {
        get {
            return "<OZLModelJournal: \(unsafeAddressOf(self))> By \(self.author?.name) on \(self.creationDate) (\(self.details.count) details)"
        }
    }
}
