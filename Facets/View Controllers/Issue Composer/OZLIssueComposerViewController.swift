//
//  OZLIssueComposerViewController.swift
//  Facets
//
//  Created by Justin Hill on 12/6/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit
import JGProgressHUD

private let CustomFieldUserInfoKey = "custom-field"

class OZLIssueComposerViewController: OZLFormViewController {

    private let ProjectKeypath = "issue.project"
    private let TrackerKeypath = "issue.tracker"
    private let StatusKeypath = "issue.status"
    private let SubjectKeypath = "issue.subject"
    private let DescriptionKeypath = "issue.description"
    private let StartDateKeypath = "issue.start-date"
    private let DueDateKeypath = "issue.due-date"
    private let CommentKeypath = "issue.update-comment"

    private enum EditMode {
        case New
        case Existing
    }

    var currentProject: OZLModelProject
    var projects = OZLModelProject.allObjects()
    var issueStatuses = OZLModelIssueStatus.allObjects()
    var customFields: [OZLModelCustomField]?
    private var editMode: EditMode

    @NSCopying var issue: OZLModelIssue

    override func viewDidLoad() {
        super.viewDidLoad()

        if issue.index > 0 {
            self.title = "\(self.issue.tracker?.name ?? "") #\(self.issue.index)"
        } else {
            self.title = "New Issue"
        }

        self.refreshCustomFields()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: #selector(submitAction))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if self.presentingViewController != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(dismissAction))
        }
    }

    func refreshCustomFields() {
        weak var weakSelf = self

        func completion(fields: [AnyObject]?, error: NSError?) {
            print(fields)

            if let fields = fields as? [OZLModelCustomField] {
                weakSelf?.customFields = fields
                weakSelf?.reloadData()
            }
        }

        if self.issue.index > 0 {
            OZLNetwork.sharedInstance().getCustomFieldsForIssue(self.issue.index, completion: completion)
        } else {
            OZLNetwork.sharedInstance().getCustomFieldsForProject(self.currentProject.projectId, completion: completion)
        }
    }

    init(currentProjectID: Int) {
        guard let project = OZLModelProject(forPrimaryKey: currentProjectID) else {
            fatalError("Tried to instantiate an issue composer without a project.")
        }

        self.currentProject = project
        self.editMode = .New
        self.issue = OZLModelIssue()
        self.issue.modelDiffingEnabled = true

        super.init(style: .Grouped)

        self.issue.projectId = project.projectId
        self.issue.tracker = project.trackers.firstObject() as? OZLModelTracker
        self.issue.status = self.issueStatuses.firstObject() as? OZLModelIssueStatus
    }

    init(issue: OZLModelIssue) {
        guard let project = OZLModelProject(forPrimaryKey: issue.projectId) else {
            fatalError("Project ID associated with passed issue is invalid")
        }

        self.issue = issue
        self.issue.modelDiffingEnabled = true

        self.currentProject = project
        self.editMode = .Existing

        super.init(style: .Grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func definitionsForFields() -> [OZLFormSection] {

        var sections = [OZLFormSection]()

        if self.editMode == .Existing {
            sections.append(OZLFormSection(
                title: "Update comment",
                fields: [
                    OZLTextViewFormField(keyPath: CommentKeypath, placeholder: "Comment", currentValue: nil)
                ]))
        }

        let generalSection = OZLFormSection(title: "General", fields: [
            OZLEnumerationFormField(keyPath: ProjectKeypath,
                placeholder: "Project",
                currentValue: self.changes[ProjectKeypath] as? RLMObject ?? self.currentProject,
                possibleRealmValues: self.projects),

            OZLEnumerationFormField(
                keyPath: TrackerKeypath,
                placeholder: "Tracker",
                currentValue: self.changes[TrackerKeypath] as? RLMObject ?? self.issue.tracker,
                possibleRealmValues: self.currentProject.trackers),

            OZLEnumerationFormField(
                keyPath: StatusKeypath,
                placeholder: "Status",
                currentValue: self.changes[StatusKeypath] as? RLMObject ?? self.issue.status,
                possibleRealmValues: self.issueStatuses),

            OZLTextFormField(
                keyPath: SubjectKeypath,
                placeholder: "Subject",
                currentValue: self.changes[SubjectKeypath] as? String ?? self.issue.subject),

            OZLTextViewFormField(
                keyPath: DescriptionKeypath,
                placeholder: "Description",
                currentValue: self.changes[DescriptionKeypath] as? String ?? self.issue.description)
        ])

        sections.append(generalSection)

        let schedulingSection = OZLFormSection(title: "Scheduling", fields: [
            OZLDateFormField(
                keyPath: StartDateKeypath,
                placeholder: "Start date",
                currentValue: self.changes[StartDateKeypath] as? NSDate ?? self.issue.startDate),

            OZLDateFormField(
                keyPath: DueDateKeypath,
                placeholder: "Due date",
                currentValue: self.changes[DueDateKeypath] as? NSDate ?? self.issue.dueDate)
        ])

        sections.append(schedulingSection)

        if let customFields = self.customFields where customFields.count > 0 {
            var fields = [OZLFormField]()

            for field in customFields {
                fields.append(field.createFormFieldForIssue(self.issue))
            }

            sections.append(OZLFormSection(title: "Custom Fields", fields: fields))
        }

        return sections
    }

    override func formFieldCell(formCell: OZLFormFieldCell, valueChangedFrom fromValue: AnyObject?, toValue: AnyObject?, atKeyPath keyPath: String, userInfo: [String : AnyObject]) {
        super.formFieldCell(formCell, valueChangedFrom:fromValue , toValue: toValue, atKeyPath: keyPath, userInfo: userInfo)

        if let customField = userInfo[CustomFieldUserInfoKey] as? OZLModelCustomField {
            if let toValue = toValue as? OZLModelStringContainer, value = toValue.value {
                self.issue.setValueOnDiff(value, forCustomFieldId: customField.fieldId)
            }
        } else if let toValue = toValue as? String {
            if keyPath == SubjectKeypath {
                self.issue.subject = toValue
            } else if keyPath == DescriptionKeypath {
                self.issue.description = toValue
            } else if keyPath == CommentKeypath {
                self.issue.setUpdateComment(toValue)
            }

        } else if let toValue = toValue as? OZLModelTracker {
            if keyPath == TrackerKeypath {
                self.issue.tracker = toValue
            }

        } else if let toValue = toValue as? OZLModelProject {
            if keyPath == ProjectKeypath {
                self.issue.projectId = toValue.projectId
            }
        } else if let toValue = toValue as? OZLModelIssueStatus {
            if keyPath == StatusKeypath {
                self.issue.status = toValue
            }
        } else if let toValue = toValue as? NSDate {
            if keyPath == DueDateKeypath {
                self.issue.dueDate = toValue
            } else if keyPath == StartDateKeypath {
                self.issue.startDate = toValue
            }
        }
        
        print("from: \(fromValue), to: \(toValue), keyPath: \(keyPath)")
    }

    func submitAction() {
        self.tableView.endEditing(true)

        print(self.issue.changeDictionary)

        let hud = JGProgressHUD(style: .Dark)
        hud.showInView(self.view)

        weak var weakSelf = self

        func completion(success: Bool, error: NSError?) {
            if let weakSelf = weakSelf {
                if success == false {
                    print(error)
                    hud.indicatorView = JGProgressHUDImageIndicatorView(imageInLibraryBundleNamed: "jg_hud_error", enableTinting: true)
                    hud.dismissAfterDelay(1.5)
                } else {
                    hud.indicatorView = JGProgressHUDImageIndicatorView(imageInLibraryBundleNamed: "jg_hud_success", enableTinting: true)

                    weak var innerWeakSelf = weakSelf
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                        if let innerWeakSelf = innerWeakSelf {
                            innerWeakSelf.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                        }
                    })
                }
            }
        }

        if self.editMode == .New {
            OZLNetwork.sharedInstance().createIssue(self.issue, withParams: [:], completion: completion)
        } else if self.editMode == .Existing {
            OZLNetwork.sharedInstance().updateIssue(self.issue, withParams: nil, completion: completion)
        }
    }

    func dismissAction() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

private extension JGProgressHUDImageIndicatorView {
    convenience init(image: UIImage!, enableTinting: Bool) {
        var image: UIImage = image

        if enableTinting {
            image = image.imageWithRenderingMode(.AlwaysTemplate)
        }

        self.init(image: image)
    }

    convenience init(imageInLibraryBundleNamed name: String, enableTinting: Bool) {
        let bundle = NSBundle(path: NSBundle(forClass: JGProgressHUD.self).pathForResource("JGProgressHUD Resources", ofType: "bundle")!)
        let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
        self.init(image: image, enableTinting: enableTinting)
    }
}

private extension OZLModelCustomField {
    func createFormFieldForIssue(issue: OZLModelIssue) -> OZLFormField {
        let fieldName = self.name ?? ""
        let keyPath = "cf_\(self.fieldId)"

        var formField: OZLFormField!

        switch self.type {
        case .Boolean:
            formField = OZLEnumerationFormField(keyPath: keyPath, placeholder: fieldName, currentValue: self.value, possibleStringValues: ["", "Yes", "No"])
        case .Date:
            formField = OZLDateFormField(keyPath: keyPath, placeholder: fieldName)
        case .Link:
            formField = OZLTextFormField(keyPath: keyPath, placeholder: fieldName)
        case .List:
            // WARNING: don't force unwrap this...
            formField = OZLEnumerationFormField(keyPath: keyPath, placeholder: fieldName, currentValue: nil, possibleRealmValues: self.options!)
        case .LongText:
            formField = OZLTextViewFormField(keyPath: keyPath, placeholder: fieldName, currentValue: self.value)
        case .Text:
            formField = OZLTextFormField(keyPath: keyPath, placeholder: fieldName, currentValue: self.value)
        case .User:
            formField = OZLTextFormField(keyPath: keyPath, placeholder: fieldName, currentValue: self.value)
        case .Version:
            // WARNING: don't force unwrap this...
            formField = OZLEnumerationFormField(keyPath: keyPath, placeholder: fieldName, currentValue: nil, possibleRealmValues: self.options!)
        default:
//            assertionFailure()
            formField = OZLFormField(keyPath: "", placeholder: "")
        }

        formField.userInfo[CustomFieldUserInfoKey] = self

        return formField
    }
}
