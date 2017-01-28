//
//  OZLJournalViewerViewModel.swift
//  Facets
//
//  Created by Justin Hill on 2/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

class OZLJournalViewerViewModel: NSObject {
    
    fileprivate let issue: OZLModelIssue
    
    init(issue: OZLModelIssue) {
        self.issue = issue
    }
    
    func numberOfJournals() -> Int {
        return self.issue.journals?.count ?? 0
    }

    func journalAtIndex(_ index: Int) -> OZLModelJournal? {
        return self.issue.journals?[self.numberOfJournals() - index - 1]
    }
}
