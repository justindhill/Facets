//
//  OZLIssueViewModel.swift
//  Facets
//
//  Created by Justin Hill on 5/6/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import Foundation

@objc protocol OZLIssueViewModelDelegate {
    func viewModel(viewModel: OZLIssueViewModel, didFinishLoadingIssueWithError error: NSError?)
    func viewModelIssueContentDidChange(viewModel: OZLIssueViewModel)
}

@objc enum OZLIssueCompleteness: Int {
    case None
    case Some
    case All
}

@objc class OZLIssueViewModel: NSObject, OZLQuickAssignDelegate {

    static let SectionDetail = "OZLIssueSectionDetail"
    static let SectionDescription = "OZLIssueSectionDescription"
    static let SectionAttachments = "OZLIssueSectionAttachments"
    static let SectionRecentActivity = "OZLIssueSectionRecentActivity"

    weak var delegate: OZLIssueViewModelDelegate?
    var successfullyFetchedIssue = false
    var currentSectionNames: [String] = []

    var issueModel: OZLModelIssue {
        didSet {
            self.updateSectionNames()
        }
    }

    init(issueModel: OZLModelIssue) {
        self.issueModel = issueModel
        
        super.init()

        self.updateSectionNames()
    }

    func updateSectionNames() {
        var sectionNames = [ OZLIssueViewModel.SectionDetail ]

        if self.issueModel.issueDescription?.characters.count ?? 0 > 0 {
            sectionNames.append(OZLIssueViewModel.SectionDescription)
        }

        if self.issueModel.attachments?.count ?? 0 > 0 {
            sectionNames.append(OZLIssueViewModel.SectionAttachments)
        }

        if self.issueModel.journals?.count ?? 0 > 0 {
            sectionNames.append(OZLIssueViewModel.SectionRecentActivity)
        }

        self.currentSectionNames = sectionNames
    }

    func completeness() -> OZLIssueCompleteness {
        if self.successfullyFetchedIssue {
            return .All
        } else if self.issueModel.subject != nil {
            return .Some
        } else {
            return .None
        }
    }

    func displayNameForSectionName(sectionName: String) -> String? {
        if sectionName == OZLIssueViewModel.SectionDescription {
            return "DESCRIPTION"
        } else if sectionName == OZLIssueViewModel.SectionAttachments {
            return "ATTACHMENTS"
        }

        return nil
    }

    func recentActivityCount() -> Int {
        return min(self.issueModel.journals?.count ?? 0, 3)
    }

    func recentActivityAtIndex(index: Int) -> OZLModelJournal {
        if let journals = self.issueModel.journals {
            return journals[journals.count - index - 1]
        }

        fatalError("Journals array doesn't exist")
    }

    func loadIssueData() {
        weak var weakSelf = self

        let params = [ "include": "attachments,journals" ]
        OZLNetwork.sharedInstance().getDetailForIssue(self.issueModel.index, withParams: params) { (issue, error) in
            if let weakSelf = weakSelf {
                if let issue = issue {
                    weakSelf.successfullyFetchedIssue = true
                    weakSelf.issueModel = issue
                }

                weakSelf.delegate?.viewModel(weakSelf, didFinishLoadingIssueWithError: error)
            }
        }
    }

    func quickAssignController(quickAssign: OZLQuickAssignViewController, didChangeAssigneeInIssue issue: OZLModelIssue, from: OZLModelUser?, to: OZLModelUser?) {
        self.issueModel = issue

        let journal = OZLModelJournal()
        journal.creationDate = NSDate()

        let detail = OZLModelJournalDetail()
        detail.type = .Attribute
        detail.oldValue = String(from?.userId)
        detail.newValue = String(to?.userId)
        detail.name = "assigned_to_id"

        journal.details = [ detail ]
        issue.journals?.append(journal)

        self.delegate?.viewModelIssueContentDidChange(self)
    }
}
