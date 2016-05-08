//
//  OZLModelIssue.swift
//  Facets
//
//  Created by Justin Hill on 4/30/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import Foundation

@objc class OZLModelIssue: NSObject, NSCopying {
    static let dateFormatter = NSDateFormatter()

    var modelDiffingEnabled: Bool = false {
        didSet(oldValue) {
            if oldValue != modelDiffingEnabled {
                self.changeDictionary = modelDiffingEnabled ? [:] : nil
            }
        }
    }
    private(set) var changeDictionary: [String: AnyObject]? = nil

    var tracker: OZLModelTracker? {
        didSet {
            if let tracker = tracker where self.modelDiffingEnabled {
                self.changeDictionary?["tracker_id"] = tracker.trackerId
            }
        }
    }

    var author: OZLModelUser? {
        didSet {
            if let author = author where self.modelDiffingEnabled {
                self.changeDictionary?["author_id"] = author.userId
            }
        }
    }

    var assignedTo: OZLModelUser? {
        didSet {
            if let assignedTo = assignedTo where self.modelDiffingEnabled {
                self.changeDictionary?["assigned_to_id"] = assignedTo.userId
            }
        }
    }

    var priority: OZLModelIssuePriority? {
        didSet {
            if let priority = priority where self.modelDiffingEnabled {
                self.changeDictionary?["priority_id"] = priority.priorityId
            }
        }
    }

    var status: OZLModelIssueStatus? {
        didSet {
            if let status = status where self.modelDiffingEnabled {
                self.changeDictionary?["status_id"] = status.statusId
            }
        }
    }

    var category: OZLModelIssueCategory? {
        didSet {
            if let category = category where self.modelDiffingEnabled {
                self.changeDictionary?["category_id"] = category.categoryId
            }
        }
    }

    var targetVersion: OZLModelVersion? {
        didSet {
            if let targetVersion = targetVersion where self.modelDiffingEnabled {
                self.changeDictionary?["fixed_version_id"] = targetVersion.versionId
            }
        }
    }

    var attachments: [OZLModelAttachment]?
    var journals: [OZLModelJournal]?
    var customFields: [OZLModelCustomField]?
    var index: Int = 0

    var projectId: Int? {
        didSet {
            if let projectId = projectId where self.modelDiffingEnabled {
                self.changeDictionary?["project_id"] = projectId
            }
        }
    }

    var parentIssueId: Int? {
        didSet {
            if let parentIssueId = parentIssueId where self.modelDiffingEnabled {
                self.changeDictionary?["parent_issue_id"] = parentIssueId
            }
        }
    }

    var subject: String? {
        didSet {
            if let subject = subject where self.modelDiffingEnabled {
                self.changeDictionary?["subject"] = subject
            }
        }
    }

    var issueDescription: String? {
        didSet {
            if let issueDescription = issueDescription where self.modelDiffingEnabled {
                self.changeDictionary?["description"] = issueDescription
            }
        }
    }

    var startDate: NSDate? {
        didSet {
            if let startDate = startDate where self.modelDiffingEnabled {
                self.changeDictionary?["start_date"] = OZLModelIssue.dateFormatter.stringFromDate(startDate)
            }
        }
    }

    var dueDate: NSDate? {
        didSet {
            if let dueDate = dueDate where self.modelDiffingEnabled {
                self.changeDictionary?["due_date"] = OZLModelIssue.dateFormatter.stringFromDate(dueDate)
            }
        }
    }

    var createdOn: NSDate? {
        didSet {
            if let createdOn = createdOn where self.modelDiffingEnabled {
                self.changeDictionary?["created_on"] = OZLModelIssue.dateFormatter.stringFromDate(createdOn)
            }
        }
    }

    var updatedOn: NSDate? {
        didSet {
            if let updatedOn = updatedOn where self.modelDiffingEnabled {
                self.changeDictionary?["updated_on"] = OZLModelIssue.dateFormatter.stringFromDate(updatedOn)
            }
        }
    }

    var doneRatio: Float? {
        didSet {
            if let doneRatio = doneRatio where self.modelDiffingEnabled {
                self.changeDictionary?["done_ratio"] = doneRatio
            }
        }
    }

    var spentHours: Float? {
        didSet {
            if let spentHours = spentHours where self.modelDiffingEnabled {
                self.changeDictionary?["spent_hours"] = spentHours
            }
        }
    }

    var estimatedHours: Float? {
        didSet {
            if let estimatedHours = estimatedHours where self.modelDiffingEnabled {
                self.changeDictionary?["estimated_hours"] = estimatedHours
            }
        }
    }

    static var classInitToken = dispatch_once_t()

    override init() {
        super.init()
        setup()
    }

    init(dictionary d: [String: AnyObject]) {
        if let id = d["id"] as? Int {
            self.index = id
        }

        if let project = d["project"], projectId = project["id"] as? Int {
            self.projectId = projectId
        }

        if let parent = d["parent"], parentId = parent["id"] as? Int {
            self.parentIssueId = parentId
        } else {
            self.parentIssueId = -1
        }

        if let tracker = d["tracker"] as? [NSObject: AnyObject] {
            self.tracker = OZLModelTracker(attributeDictionary: tracker)
        }

        if let author = d["author"] as? [NSObject: AnyObject] {
            self.author = OZLModelUser(attributeDictionary: author)
        }

        if let assignedTo = d["assigned_to"] as? [NSObject: AnyObject] {
            self.assignedTo = OZLModelUser(attributeDictionary: assignedTo)
        }

        if let priority = d["priority"] as? [NSObject: AnyObject] {
            self.priority = OZLModelIssuePriority(attributeDictionary: priority)
        }

        if let status = d["status"] as? [NSObject: AnyObject] {
            self.status = OZLModelIssueStatus(attributeDictionary: status)
        }

        if let customFields = d["custom_fields"] as? [[NSObject: AnyObject]] {
            self.customFields = customFields.map({ (field) -> OZLModelCustomField in
                return OZLModelCustomField(attributeDictionary: field)
            })
        }

        self.subject = d["subject"] as? String
        self.issueDescription = d["description"] as? String

        if let startDate = d["start_date"] as? String {
            self.startDate = NSDate(ISO8601String: startDate)
        }

        if let dueDate = d["due_date"] as? String {
            self.dueDate = NSDate(ISO8601String: dueDate)
        }

        if let createdOn = d["created_on"] as? String {
            self.createdOn = NSDate(ISO8601String: createdOn)
        }

        if let updatedOn = d["updated_on"] as? String {
            self.updatedOn = NSDate(ISO8601String: updatedOn)
        }

        if let doneRatio = d["done_ratio"] as? Float {
            self.doneRatio = doneRatio
        }

        if let targetVersion = d["fixed_version"] as? [NSObject: AnyObject] {
            self.targetVersion = OZLModelVersion(attributeDictionary: targetVersion)
        }

        if let spentHours = d["spent_hours"] as? Float {
            self.spentHours = spentHours
        }

        if let estimatedHours = d["estimated_hours"] as? Float {
            self.estimatedHours = estimatedHours
        }

        if let attachments = d["attachments"] as? [[NSObject: AnyObject]] {
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
        dispatch_once(&OZLModelIssue.classInitToken) {
            OZLModelIssue.dateFormatter.dateFormat = "yyyy-MM-dd"
        }
    }

    func setUpdateComment(comment: String) {
        if self.modelDiffingEnabled {
            self.changeDictionary?["notes"] = comment
        }
    }

    func setValueOnDiff(value: AnyObject, forCustomFieldId fieldId: Int) {
        guard value is String || value is Int || value is Float else {
            fatalError()
        }

        if var changeDictionary = self.changeDictionary {
            if changeDictionary["custom_fields"] == nil {
                changeDictionary["custom_fields"] = [Int: AnyObject]()
            }

            if var customFields = changeDictionary["custom_fields"] as? [Int: AnyObject] where fieldId > 0 {
                customFields[fieldId] = value
            }
        }

    }

    class func displayValueForAttributeName(name: String?, attributeId id: Int) -> String? {
        if let name = name {
            switch name {
                case "project_id": return OZLModelProject(forPrimaryKey: id)?.name
                case "tracker_id": return OZLModelTracker(forPrimaryKey: id)?.name
                case "fixed_version_id": return OZLModelVersion(forPrimaryKey: id)?.name
                case "status_id": return OZLModelIssueStatus(forPrimaryKey: id)?.name
                case "assigned_to_id": return OZLModelUser(forPrimaryKey: id)?.name
                case "category_id": return OZLModelIssueCategory(forPrimaryKey: id)?.name
                case "priority_id": return OZLModelIssuePriority(forPrimaryKey: id)?.name

                default:
                    return String(id)
            }
        }

        return nil
    }

    class func displayNameForAttributeName(name: String?) -> String {
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
                    return name ?? ""
            }
        }

        return ""
    }

    func copyWithZone(zone: NSZone) -> AnyObject {
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
