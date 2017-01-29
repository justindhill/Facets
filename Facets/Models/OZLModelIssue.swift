//
//  OZLModelIssue.swift
//  Facets
//
//  Created by Justin Hill on 4/30/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import Foundation

@objc class OZLModelIssue: NSObject, NSCopying {
    private static var __once: () = {
            OZLModelIssue.dateFormatter.dateFormat = "yyyy-MM-dd"
        }()
    static let dateFormatter = DateFormatter()

    var modelDiffingEnabled: Bool = false {
        didSet(oldValue) {
            if oldValue != modelDiffingEnabled {
                self.changeDictionary = modelDiffingEnabled ? [:] : nil
            }
        }
    }
    fileprivate(set) var changeDictionary: [String: AnyObject]? = nil

    var tracker: OZLModelTracker? {
        didSet {
            if let tracker = tracker, self.modelDiffingEnabled {
                self.changeDictionary?["tracker_id"] = tracker.trackerId as AnyObject?
            }
        }
    }

    var author: OZLModelUser? {
        didSet {
            if let author = author, self.modelDiffingEnabled {
                self.changeDictionary?["author_id"] = author.userId as AnyObject?
            }
        }
    }

    var assignedTo: OZLModelUser? {
        didSet {
            if let assignedTo = assignedTo, self.modelDiffingEnabled {
                self.changeDictionary?["assigned_to_id"] = assignedTo.userId as AnyObject?
            }
        }
    }

    var priority: OZLModelIssuePriority? {
        didSet {
            if let priority = priority, self.modelDiffingEnabled {
                self.changeDictionary?["priority_id"] = priority.priorityId as AnyObject?
            }
        }
    }

    var status: OZLModelIssueStatus? {
        didSet {
            if let status = status, self.modelDiffingEnabled {
                self.changeDictionary?["status_id"] = status.statusId as AnyObject?
            }
        }
    }

    var category: OZLModelIssueCategory? {
        didSet {
            if let category = category, self.modelDiffingEnabled {
                self.changeDictionary?["category_id"] = category.categoryId as AnyObject?
            }
        }
    }

    var targetVersion: OZLModelVersion? {
        didSet {
            if let targetVersion = targetVersion, self.modelDiffingEnabled {
                self.changeDictionary?["fixed_version_id"] = targetVersion.versionId as AnyObject?
            }
        }
    }

    var attachments: [OZLModelAttachment]?
    var journals: [OZLModelJournal]?
    var customFields: [OZLModelCustomField]?
    var index: Int = 0

    var projectId: Int? {
        didSet {
            if let projectId = projectId, self.modelDiffingEnabled {
                self.changeDictionary?["project_id"] = projectId as AnyObject?
            }
        }
    }

    var parentIssueId: Int? {
        didSet {
            if let parentIssueId = parentIssueId, self.modelDiffingEnabled {
                self.changeDictionary?["parent_issue_id"] = parentIssueId as AnyObject?
            }
        }
    }

    var subject: String? {
        didSet {
            if let subject = subject, self.modelDiffingEnabled {
                self.changeDictionary?["subject"] = subject as AnyObject?
            }
        }
    }

    var issueDescription: String? {
        didSet {
            if let issueDescription = issueDescription, self.modelDiffingEnabled {
                self.changeDictionary?["description"] = issueDescription as AnyObject?
            }
        }
    }

    var startDate: Date? {
        didSet {
            if let startDate = startDate, self.modelDiffingEnabled {
                self.changeDictionary?["start_date"] = OZLModelIssue.dateFormatter.string(from: startDate) as AnyObject?
            }
        }
    }

    var dueDate: Date? {
        didSet {
            if let dueDate = dueDate, self.modelDiffingEnabled {
                self.changeDictionary?["due_date"] = OZLModelIssue.dateFormatter.string(from: dueDate) as AnyObject?
            }
        }
    }

    var createdOn: Date? {
        didSet {
            if let createdOn = createdOn, self.modelDiffingEnabled {
                self.changeDictionary?["created_on"] = OZLModelIssue.dateFormatter.string(from: createdOn) as AnyObject?
            }
        }
    }

    var updatedOn: Date? {
        didSet {
            if let updatedOn = updatedOn, self.modelDiffingEnabled {
                self.changeDictionary?["updated_on"] = OZLModelIssue.dateFormatter.string(from: updatedOn) as AnyObject?
            }
        }
    }

    var doneRatio: Float? {
        didSet {
            if let doneRatio = doneRatio, self.modelDiffingEnabled {
                self.changeDictionary?["done_ratio"] = doneRatio as AnyObject?
            }
        }
    }

    var spentHours: Float? {
        didSet {
            if let spentHours = spentHours, self.modelDiffingEnabled {
                self.changeDictionary?["spent_hours"] = spentHours as AnyObject?
            }
        }
    }

    var estimatedHours: Float? {
        didSet {
            if let estimatedHours = estimatedHours, self.modelDiffingEnabled {
                self.changeDictionary?["estimated_hours"] = estimatedHours as AnyObject?
            }
        }
    }

    static var classInitToken = Int()

    override init() {
        super.init()
        setup()
    }

    init(dictionary d: [String: AnyObject]) {
        if let id = d["id"] as? Int {
            self.index = id
        }

        if let project = d["project"] as? [String: AnyObject], let projectId = project["id"] as? Int {
            self.projectId = projectId
        }

        if let parent = d["parent"] as? [String: AnyObject], let parentId = parent["id"] as? Int {
            self.parentIssueId = parentId
        } else {
            self.parentIssueId = -1
        }

        if let tracker = d["tracker"] as? [AnyHashable: Any] {
            self.tracker = OZLModelTracker(attributeDictionary: tracker)
        }

        if let author = d["author"] as? [AnyHashable: Any] {
            self.author = OZLModelUser(attributeDictionary: author)
        }

        if let assignedTo = d["assigned_to"] as? [AnyHashable: Any] {
            self.assignedTo = OZLModelUser(attributeDictionary: assignedTo)
        }

        if let category = d["category"] as? [AnyHashable: Any] {
            self.category = OZLModelIssueCategory(attributeDictionary: category)
        }

        if let priority = d["priority"] as? [AnyHashable: Any] {
            self.priority = OZLModelIssuePriority(attributeDictionary: priority)
        }

        if let status = d["status"] as? [AnyHashable: Any] {
            self.status = OZLModelIssueStatus(attributeDictionary: status)
        }

        if let customFields = d["custom_fields"] as? [[AnyHashable: Any]] {
            self.customFields = customFields.map({ (field) -> OZLModelCustomField in
                return OZLModelCustomField(attributeDictionary: field)
            })
        }

        self.subject = d["subject"] as? String
        self.issueDescription = d["description"] as? String

        if let startDate = d["start_date"] as? String {
            self.startDate = NSDate(iso8601String: startDate) as Date?
        }

        if let dueDate = d["due_date"] as? String {
            self.dueDate = NSDate(iso8601String: dueDate) as Date?
        }

        if let createdOn = d["created_on"] as? String {
            self.createdOn = NSDate(iso8601String: createdOn) as Date?
        }

        if let updatedOn = d["updated_on"] as? String {
            self.updatedOn = NSDate(iso8601String: updatedOn) as Date?
        }

        if let doneRatio = d["done_ratio"] as? Float {
            self.doneRatio = doneRatio
        }

        if let targetVersion = d["fixed_version"] as? [AnyHashable: Any] {
            self.targetVersion = OZLModelVersion(attributeDictionary: targetVersion)
        }

        if let spentHours = d["spent_hours"] as? Float {
            self.spentHours = spentHours
        }

        if let estimatedHours = d["estimated_hours"] as? Float {
            self.estimatedHours = estimatedHours
        }

        if let attachments = d["attachments"] as? [[AnyHashable: Any]] {
            self.attachments = attachments.map({ (attachment) -> OZLModelAttachment in
                return OZLModelAttachment(dictionary: attachment)
            })
        }

        if let journals = d["journals"] as? [[String: AnyObject]] {
            self.journals = journals.map({ (journal) -> OZLModelJournal in
                return OZLModelJournal(attributes: journal)
            })
        }

        super.init()
        setup()
    }

    func setup() {
        _ = OZLModelIssue.__once
    }

    func setUpdateComment(_ comment: String) {
        if self.modelDiffingEnabled {
            self.changeDictionary?["notes"] = comment as AnyObject?
        }
    }

    func setValueOnDiff(_ value: AnyObject, forCustomFieldId fieldId: Int) {
        guard value is String || value is Int || value is Float else {
            fatalError()
        }

        if var changeDictionary = self.changeDictionary {
            if changeDictionary["custom_fields"] == nil {
                changeDictionary["custom_fields"] = [Int: AnyObject]() as AnyObject?
            }

            if var customFields = changeDictionary["custom_fields"] as? [Int: AnyObject], fieldId > 0 {
                customFields[fieldId] = value
            }
        }

    }

    class func displayValueForAttributeName(_ name: String?, attributeId id: Int) -> String? {
        if let name = name {
            switch name {
                case "project_id": return OZLModelProject(forPrimaryKey: id)?.name
                case "tracker_id": return OZLModelTracker(forPrimaryKey: id)?.name
                case "fixed_version_id": return OZLModelVersion(forPrimaryKey: id)?.name
                case "status_id": return OZLModelIssueStatus(forPrimaryKey: id)?.name
                case "assigned_to_id": return OZLModelUser(forPrimaryKey: String(id))?.name
                case "category_id": return OZLModelIssueCategory(forPrimaryKey: id)?.name
                case "priority_id": return OZLModelIssuePriority(forPrimaryKey: id)?.name

                default:
                    return String(id)
            }
        }

        return nil
    }

    class func displayNameForAttributeName(_ name: String?) -> String {
        if let name = name {
            switch name {
                case "author": return "Author"
                case "project_id": return "Project"
                case "tracker_id": return "Tracker"
                case "fixed_version_id": return "Target version"
                case "status_id": return "Status"
                case "assigned_to_id": return "Assignee"
                case "category_id": return "Category"
                case "priority_id": return "Priority"
                case "due_date": return "Due date"
                case "start_date": return "Start date"
                case "done_ratio": return "Percent complete"
                case "spent_hours": return "Spent hours"
                case "estimated_hours": return "Estimated hours"
                case "description": return "Description"
                case "subject": return "Subject"

                default:
                    assertionFailure("We were asked for a display name for an attribute we don't know of!")
                    return name
            }
        }

        return ""
    }

    func copy(with zone: NSZone?) -> Any {
        let copy = OZLModelIssue()
        copy.index = self.index
        copy.projectId = self.projectId
        copy.parentIssueId = self.parentIssueId
        copy.tracker = self.tracker
        copy.author = self.author
        copy.assignedTo = self.assignedTo
        copy.priority = self.priority
        copy.status = self.status
        copy.category = self.category
        copy.targetVersion = self.targetVersion
        copy.customFields = self.customFields
        copy.subject = self.subject
        copy.issueDescription = self.issueDescription
        copy.startDate = self.startDate
        copy.dueDate = self.dueDate
        copy.createdOn = self.createdOn
        copy.updatedOn = self.updatedOn
        copy.doneRatio = self.doneRatio
        copy.spentHours = self.spentHours
        copy.estimatedHours = self.estimatedHours
        copy.attachments = self.attachments
        copy.journals = self.journals
        
        return copy
    }
}
