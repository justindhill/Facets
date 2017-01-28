//
//  OZLModelJournal.swift
//  Facets
//
//  Created by Justin Hill on 11/26/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit
import ISO8601

class OZLModelJournal: NSObject {
    
    var author: OZLModelUser? = nil
    var notes: String? = nil
    var journalId: Int? = nil
    var creationDate: Date? = nil
    var details: Array<OZLModelJournalDetail> = []
    
    override init() {
        super.init()
    }
    
    convenience init(attributes: Dictionary<String, AnyObject>) {
        self.init()
        
        if let authorDict = attributes["user"] as? Dictionary<String, AnyObject> {
            self.author = OZLModelUser(attributeDictionary: authorDict)
        }
        
        self.notes = attributes["notes"] as? String
        self.journalId = attributes["id"] as? Int
        
        if let dateString = attributes["created_on"] as? String {
            self.creationDate = NSDate(iso8601String: dateString) as? Date
        }
        
        if let details = attributes["details"] as? Array<Dictionary<String, AnyObject>> {
            var detailModels: Array<OZLModelJournalDetail> = []
            for detailDict in details {
                detailModels.append(OZLModelJournalDetail(attributes: detailDict))
            }
            
            self.details = detailModels
        }
    }
    
    override var description: String {
        get {
            return "<OZLModelJournal: \(Unmanaged.passUnretained(self).toOpaque())> By \(self.author?.name) on \(self.creationDate) (\(self.details.count) details)"
        }
    }
}
