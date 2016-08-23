//
//  OZLIssueViewModel.swift
//  Facets
//
//  Created by Justin Hill on 5/6/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import Foundation
import Jiramazing

protocol OZLIssueViewModelDelegate: AnyObject {
    func viewModel(viewModel: OZLIssueViewModel, didFinishLoadingIssueWithError error: NSError?)
    func viewModelDetailDisplayModeDidChange(viewModel: OZLIssueViewModel)
    func viewModelIssueContentDidChange(viewModel: OZLIssueViewModel)
}

enum OZLIssueCompleteness: Int {
    case None
    case Some
    case All
}

@objc class OZLIssueViewModel: NSObject, OZLQuickAssignDelegate {

    private static let PinnedIdentifiersDefaultsKeypath = "facets.issue.pinned-detail-identifiers"

    static let SectionDetail = "OZLIssueSectionDetail"
    static let SectionDescription = "OZLIssueSectionDescription"
    static let SectionAttachments = "OZLIssueSectionAttachments"
    static let SectionRecentActivity = "OZLIssueSectionRecentActivity"

    private static let defaultPinnedDetailIdentifiers: Set<String> = ["status_id", "category_id", "priority_id", "fixed_version_id"]
    private var pinnedDetailIdentifiers = OZLIssueViewModel.defaultPinnedDetailIdentifiers

    var showAllDetails = false {
        didSet(oldValue) {
            if self.showAllDetails != oldValue {
                self.refreshVisibleDetails()
                self.delegate?.viewModelDetailDisplayModeDidChange(self)
            }
        }
    }

    // (identifier, displayName, displayValue)
    private var details: [(String, String, String)] = []
    private var visibleDetails: [(String, String, String)] = []

    weak var delegate: OZLIssueViewModelDelegate?
    var successfullyFetchedIssue = false
    var currentSectionNames: [String] = []

    var issueModel: Issue {
        didSet {
            self.updateSectionNames()
        }
    }

    // MARK: - Life cycle
    init(issueModel: Issue) {
        self.issueModel = issueModel
        
        super.init()

        let keyPath = self.targetedPinnedIdentifiersDefaultsKeypath()
        if let storedIdentifiers = NSUserDefaults.standardUserDefaults().arrayForKey(keyPath) as? [String] {
            self.pinnedDetailIdentifiers = Set(storedIdentifiers)
        }

        self.updateSectionNames()
        self.refreshVisibleDetails()
    }

    func targetedPinnedIdentifiersDefaultsKeypath() -> String {
        return "\(OZLIssueViewModel.PinnedIdentifiersDefaultsKeypath).\(self.issueModel.id)"
    }

    // MARK: - Behavior
    func updateSectionNames() {
        var sectionNames = [ OZLIssueViewModel.SectionDetail ]

        if self.issueModel.issueDescription?.characters.count ?? 0 > 0 {
            sectionNames.append(OZLIssueViewModel.SectionDescription)
        }

        if self.issueModel.attachments?.count ?? 0 > 0 {
            sectionNames.append(OZLIssueViewModel.SectionAttachments)
        }

        self.currentSectionNames = sectionNames
    }

    func completeness() -> OZLIssueCompleteness {
        if self.successfullyFetchedIssue {
            return .All
        } else if self.issueModel.summary != nil {
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
        } else if sectionName == OZLIssueViewModel.SectionRecentActivity {
            return "RECENT ACTIVITY"
        }

        return nil
    }

    func sectionNumberForSectionName(sectionName: String) -> Int? {
        return self.currentSectionNames.indexOf(sectionName)
    }

    func loadIssueData() {
        weak var weakSelf = self

        let params = [ "include": "attachments,journals,relations" ]
        // WARNING: issue detail fetching
//        OZLNetwork.sharedInstance().getDetailForIssue(self.issueModel.index, withParams: params) { (issue, error) in
//            if let weakSelf = weakSelf {
//                if let issue = issue {
//                    weakSelf.successfullyFetchedIssue = true
//                    weakSelf.issueModel = issue
//                }
//
//                weakSelf.delegate?.viewModel(weakSelf, didFinishLoadingIssueWithError: error)
//            }
//        }
    }

    func refreshVisibleDetails() {
        var visibleDetails: [(String, String, String)] = []

        for (index, (identifier, _, _)) in self.details.enumerate() {
            if self.pinnedDetailIdentifiers.contains(identifier) || self.showAllDetails {
                visibleDetails.append(self.details[index])
            }
        }

        self.visibleDetails = visibleDetails
    }

    func numberOfDetails() -> Int {
        return self.visibleDetails.count
    }

    func detailAtIndex(index: Int) -> (String, String, Bool) {
        let (identifier, name, value) = self.visibleDetails[index]

        return (name, value, self.pinnedDetailIdentifiers.contains(identifier))
    }

    func togglePinningForDetailAtIndex(index: Int) {
        let (identifier, _, _) = self.details[index]

        if self.pinnedDetailIdentifiers.contains(identifier) {
            self.pinnedDetailIdentifiers.remove(identifier)
        } else {
            self.pinnedDetailIdentifiers.insert(identifier)
        }

        NSUserDefaults.standardUserDefaults().setObject(Array(self.pinnedDetailIdentifiers), forKey: self.targetedPinnedIdentifiersDefaultsKeypath())
    }

    // MARK: - Recent activity
    func recentActivityCount() -> Int {
        return min(self.issueModel.comments?.count ?? 0, 3)
    }

    func recentActivityAtIndex(index: Int) -> Comment {
        if let comments = self.issueModel.comments {
            return comments[comments.count - index - 1]
        }

        fatalError("Journals array doesn't exist")
    }

    // MARK: - Quick assign delegate
    func quickAssignController(quickAssign: OZLQuickAssignViewController, didChangeAssigneeInIssue issue: Issue, from: User?, to: User?) {
        self.issueModel = issue

        // WARNING: handle quick assign changes!

        self.delegate?.viewModelIssueContentDidChange(self)
    }
}
