//
//  OZLIssueViewModel.swift
//  Facets
//
//  Created by Justin Hill on 5/6/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import Foundation

protocol OZLIssueViewModelDelegate: AnyObject {
    func viewModel(_ viewModel: OZLIssueViewModel, didFinishLoadingIssueWithError error: NSError?)
    func viewModelDetailDisplayModeDidChange(_ viewModel: OZLIssueViewModel)
    func viewModelIssueContentDidChange(_ viewModel: OZLIssueViewModel)
}

enum OZLIssueCompleteness: Int {
    case none
    case some
    case all
}

@objc class OZLIssueViewModel: NSObject, OZLQuickAssignDelegate {

    fileprivate static let PinnedIdentifiersDefaultsKeypath = "facets.issue.pinned-detail-identifiers"

    static let SectionDetail = "OZLIssueSectionDetail"
    static let SectionDescription = "OZLIssueSectionDescription"
    static let SectionAttachments = "OZLIssueSectionAttachments"
    static let SectionRecentActivity = "OZLIssueSectionRecentActivity"

    fileprivate static let defaultPinnedDetailIdentifiers: Set<String> = ["status_id", "category_id", "priority_id", "fixed_version_id"]
    fileprivate var pinnedDetailIdentifiers = OZLIssueViewModel.defaultPinnedDetailIdentifiers

    var showAllDetails = false {
        didSet(oldValue) {
            if self.showAllDetails != oldValue {
                self.refreshVisibleDetails()
                self.delegate?.viewModelDetailDisplayModeDidChange(self)
            }
        }
    }

    // (identifier, displayName, displayValue)
    fileprivate var details: [(String, String, String)] = []
    fileprivate var visibleDetails: [(String, String, String)] = []

    weak var delegate: OZLIssueViewModelDelegate?
    var successfullyFetchedIssue = false
    var currentSectionNames: [String] = []

    var issueModel: OZLModelIssue {
        didSet {
            self.updateSectionNames()
            self.refreshDetails()
        }
    }

    // MARK: - Life cycle
    init(issueModel: OZLModelIssue) {
        self.issueModel = issueModel
        
        super.init()

        let keyPath = self.targetedPinnedIdentifiersDefaultsKeypath()
        if let storedIdentifiers = UserDefaults.standard.array(forKey: keyPath) as? [String] {
            self.pinnedDetailIdentifiers = Set(storedIdentifiers)
        }

        self.updateSectionNames()
        self.refreshDetails()
        self.refreshVisibleDetails()
    }

    func targetedPinnedIdentifiersDefaultsKeypath() -> String {
        return "\(OZLIssueViewModel.PinnedIdentifiersDefaultsKeypath).\(self.issueModel.projectId)"
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

        if self.issueModel.journals?.count ?? 0 > 0 {
            sectionNames.append(OZLIssueViewModel.SectionRecentActivity)
        }

        self.currentSectionNames = sectionNames
    }

    func completeness() -> OZLIssueCompleteness {
        if self.successfullyFetchedIssue {
            return .all
        } else if self.issueModel.subject != nil {
            return .some
        } else {
            return .none
        }
    }

    func displayNameForSectionName(_ sectionName: String) -> String? {
        if sectionName == OZLIssueViewModel.SectionDescription {
            return "DESCRIPTION"
        } else if sectionName == OZLIssueViewModel.SectionAttachments {
            return "ATTACHMENTS"
        } else if sectionName == OZLIssueViewModel.SectionRecentActivity {
            return "RECENT ACTIVITY"
        }

        return nil
    }

    func sectionNumberForSectionName(_ sectionName: String) -> Int? {
        return self.currentSectionNames.index(of: sectionName)
    }

    func loadIssueData() {
        weak var weakSelf = self

        let params = [ "include": "attachments,journals,relations" ]
        OZLNetwork.sharedInstance().getDetailForIssue(self.issueModel.index, withParams: params) { (issue, error) in
            if let weakSelf = weakSelf {
                if let issue = issue {
                    weakSelf.successfullyFetchedIssue = true
                    weakSelf.issueModel = issue
                }

                weakSelf.delegate?.viewModel(weakSelf, didFinishLoadingIssueWithError: error as NSError?)
            }
        }
    }

    // MARK: - Details
    func refreshDetails() {
        var details = [(String, String, String)]()

        if let status = self.issueModel.status?.name {
            details.append(("status_id", OZLModelIssue.displayNameForAttributeName("status_id"), status))
        }

        if let priority = self.issueModel.priority?.name {
            details.append(("priority_id", OZLModelIssue.displayNameForAttributeName("priority_id"), priority))
        }

        if let author = self.issueModel.author?.name {
            details.append(("author", OZLModelIssue.displayNameForAttributeName("author"), author))
        }

        if let startDate = self.issueModel.startDate {
            details.append(("start_date", OZLModelIssue.displayNameForAttributeName("start_date"), String(describing: startDate)))
        }
        
        if let dueDate = self.issueModel.dueDate {
            details.append(("due_date", OZLModelIssue.displayNameForAttributeName("due_date"), String(describing: dueDate)))
        }

        if let category = self.issueModel.category {
            details.append(("category_id", OZLModelIssue.displayNameForAttributeName("category_id"), category.name))
        }

        if let targetVersion = self.issueModel.targetVersion {
            details.append(("fixed_version_id", OZLModelIssue.displayNameForAttributeName("fixed_version_id"), targetVersion.name))
        }

        if let doneRatio = self.issueModel.doneRatio {
            details.append(("done_ratio", OZLModelIssue.displayNameForAttributeName("done_ratio"), String(doneRatio)))
        }

        if let spentHours = self.issueModel.spentHours {
            details.append(("spent_hours", OZLModelIssue.displayNameForAttributeName("spent_hours"), String(spentHours)))
        }

        for field in self.issueModel.customFields ?? [] where field.value != nil {
            let cachedField = OZLModelCustomField(forPrimaryKey: field.fieldId)
            
            details.append(
                (
                    String(field.fieldId),
                    field.name ?? "",
                    OZLModelCustomField.displayValue(for: cachedField?.type ?? field.type, attributeId: field.fieldId, attributeValue: field.value ?? "")
                )
            )
        }

        self.details = details
    }

    func refreshVisibleDetails() {
        var visibleDetails: [(String, String, String)] = []

        for (index, (identifier, _, _)) in self.details.enumerated() {
            if self.pinnedDetailIdentifiers.contains(identifier) || self.showAllDetails {
                visibleDetails.append(self.details[index])
            }
        }

        self.visibleDetails = visibleDetails
    }

    func numberOfDetails() -> Int {
        return self.visibleDetails.count
    }

    func detailAtIndex(_ index: Int) -> (String, String, Bool) {
        let (identifier, name, value) = self.visibleDetails[index]

        return (name, value, self.pinnedDetailIdentifiers.contains(identifier))
    }

    func togglePinningForDetailAtIndex(_ index: Int) {
        let (identifier, _, _) = self.details[index]

        if self.pinnedDetailIdentifiers.contains(identifier) {
            self.pinnedDetailIdentifiers.remove(identifier)
        } else {
            self.pinnedDetailIdentifiers.insert(identifier)
        }

        UserDefaults.standard.set(Array(self.pinnedDetailIdentifiers), forKey: self.targetedPinnedIdentifiersDefaultsKeypath())
    }

    // MARK: - Recent activity
    func recentActivityCount() -> Int {
        return min(self.issueModel.journals?.count ?? 0, 3)
    }

    func recentActivityAtIndex(_ index: Int) -> OZLModelJournal {
        if let journals = self.issueModel.journals {
            return journals[journals.count - index - 1]
        }

        fatalError("Journals array doesn't exist")
    }

    // MARK: - Quick assign delegate
    func quickAssignController(_ quickAssign: OZLQuickAssignViewController, didChangeAssigneeInIssue issue: OZLModelIssue, from: OZLModelUser?, to: OZLModelUser?) {
        self.issueModel = issue

        let journal = OZLModelJournal()
        journal.creationDate = Date()

        let detail = OZLModelJournalDetail()
        detail.type = .attribute
        detail.oldValue = String(describing: from?.userId)
        detail.newValue = String(describing: to?.userId)
        detail.name = "assigned_to_id"

        journal.details = [ detail ]
        issue.journals?.append(journal)

        self.delegate?.viewModelIssueContentDidChange(self)
    }
}
