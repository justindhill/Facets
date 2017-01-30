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

    fileprivate let ProjectKeypath = "issue.project"
    fileprivate let TrackerKeypath = "issue.tracker"
    fileprivate let StatusKeypath = "issue.status"
    fileprivate let SubjectKeypath = "issue.subject"
    fileprivate let DescriptionKeypath = "issue.description"
    fileprivate let StartDateKeypath = "issue.start-date"
    fileprivate let DueDateKeypath = "issue.due-date"
    fileprivate let CommentKeypath = "issue.update-comment"
    fileprivate let TargetVersionKeypath = "issue.target-version"
    fileprivate let CategoryKeypath = "issue.category"
    fileprivate let AssigneeKeypath = "issue.assignee"
    fileprivate let TimeEstimationKeypath = "issue.estimated-time"
    fileprivate let PercentCompleteKeypath = "issue.percent-complete"

    fileprivate enum EditMode {
        case new
        case existing
    }

    var currentProject: OZLModelProject
    var projects = OZLModelProject.allObjects()
    var versions = OZLModelVersion.allObjects()
    var categories = OZLModelIssueCategory.allObjects()
    var issueStatuses = OZLModelIssueStatus.allObjects()
    var users = OZLModelUser.allObjects()
    var customFields: [OZLModelCustomField]?
    fileprivate var editMode: EditMode

    @NSCopying var issue: OZLModelIssue

    override func viewDidLoad() {
        super.viewDidLoad()

        if issue.index > 0 {
            self.title = "\(self.issue.tracker?.name ?? "") #\(self.issue.index)"
        } else {
            self.title = "New Issue"
        }

        self.refreshCustomFields()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitAction))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.presentingViewController != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissAction))
        }
    }

    func refreshCustomFields() {
        weak var weakSelf = self

        func completion(_ fields: [Any]?, error: Error?) {
            if let fields = fields as? [OZLModelCustomField] {
                weakSelf?.customFields = fields
                weakSelf?.reloadData()
            }
        }

        if self.issue.index > 0 {
            OZLNetwork.sharedInstance().getCustomFields(forIssue: self.issue.index, completion: completion)
        } else {
            OZLNetwork.sharedInstance().getCustomFields(forProject: self.currentProject.projectId, completion: completion)
        }
    }

    init(currentProjectID: Int) {
        guard let project = OZLModelProject(forPrimaryKey: currentProjectID) else {
            fatalError("Tried to instantiate an issue composer without a project.")
        }

        self.currentProject = project
        self.editMode = .new
        self.issue = OZLModelIssue()
        self.issue.modelDiffingEnabled = true

        super.init(style: .grouped)

        self.issue.projectId = project.projectId
        self.issue.tracker = project.trackers.firstObject()
        self.issue.status = self.issueStatuses.firstObject() as? OZLModelIssueStatus
    }

    init(issue: OZLModelIssue) {
        guard let project = OZLModelProject(forPrimaryKey: issue.projectId) else {
            fatalError("Project ID associated with passed issue is invalid")
        }

        self.issue = issue
        self.issue.modelDiffingEnabled = true

        self.currentProject = project
        self.editMode = .existing

        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func definitionsForFields() -> [OZLFormSection] {

        var sections = [OZLFormSection]()

        if self.editMode == .existing {
            sections.append(OZLFormSection(
                title: "Update comment",
                fields: [
                    OZLTextViewFormField(keyPath: CommentKeypath, placeholder: "Comment", currentValue: nil)
                ]))
        }

        let generalSection = OZLFormSection(title: "General", fields: [
            OZLEnumerationFormField(keyPath: ProjectKeypath,
                placeholder: "Project",
                currentValue: (self.changes[ProjectKeypath] as? OZLEnumerationFormFieldValue)?.stringValue() ?? self.currentProject.name,
                possibleRealmValues: self.projects),

            OZLEnumerationFormField(
                keyPath: TrackerKeypath,
                placeholder: "Tracker",
                currentValue: (self.changes[TrackerKeypath] as? OZLEnumerationFormFieldValue)?.stringValue() ?? self.issue.tracker?.name,
                possibleRealmValues: self.currentProject.trackers),

            OZLEnumerationFormField(
                keyPath: StatusKeypath,
                placeholder: "Status",
                currentValue: (self.changes[StatusKeypath] as? OZLEnumerationFormFieldValue)?.stringValue() ?? self.issue.status?.name,
                possibleRealmValues: self.issueStatuses),

            OZLEnumerationFormField(
                keyPath: CategoryKeypath,
                placeholder: "Category",
                currentValue: (self.changes[CategoryKeypath] as? OZLEnumerationFormFieldValue)?.stringValue() ?? self.issue.category?.name,
                possibleRealmValues: self.categories),

            OZLEnumerationFormField(
                keyPath: AssigneeKeypath,
                placeholder: "Assignee",
                currentValue: (self.changes[AssigneeKeypath] as? OZLEnumerationFormFieldValue)?.stringValue() ?? self.issue.assignedTo?.name,
                possibleRealmValues: self.users),

            OZLTextFormField(
                keyPath: SubjectKeypath,
                placeholder: "Subject",
                currentValue: self.changes[SubjectKeypath] as? String ?? self.issue.subject),

            OZLTextViewFormField(
                keyPath: DescriptionKeypath,
                placeholder: "Description",
                currentValue: self.changes[DescriptionKeypath] as? String ?? self.issue.issueDescription)
        ])

        sections.append(generalSection)

        let schedulingSection = OZLFormSection(title: "Scheduling", fields: [
            OZLEnumerationFormField(
                keyPath: TargetVersionKeypath,
                placeholder: "Target version",
                currentValue: (self.changes[TargetVersionKeypath] as? OZLEnumerationFormFieldValue)?.stringValue() ?? self.issue.targetVersion?.name,
                possibleRealmValues: self.versions),

            OZLTextFormField(
                keyPath: TimeEstimationKeypath,
                placeholder: "Estimated time",
                currentValue: (self.changes[TimeEstimationKeypath] as? String) ?? String(describing: self.issue.estimatedHours)),

            OZLTextFormField(
                keyPath: PercentCompleteKeypath,
                placeholder: "Percent complete",
                currentValue: (self.changes[PercentCompleteKeypath] as? String ?? String(describing: self.issue.doneRatio))),

            OZLDateFormField(
                keyPath: StartDateKeypath,
                placeholder: "Start date",
                currentValue: self.changes[StartDateKeypath] as? Date ?? self.issue.startDate),

            OZLDateFormField(
                keyPath: DueDateKeypath,
                placeholder: "Due date",
                currentValue: self.changes[DueDateKeypath] as? Date ?? self.issue.dueDate)
        ])

        sections.append(schedulingSection)

        if let customFields = self.customFields, customFields.count > 0 {
            var fields = [OZLFormField]()

            for field in customFields {
                fields.append(field.createFormFieldForIssue(self.issue))
            }

            sections.append(OZLFormSection(title: "Custom Fields", fields: fields))
            self.tableView.tableFooterView = nil
        } else {
            let loadingView = OZLLoadingView(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
            loadingView.startLoading()
            loadingView.backgroundColor = UIColor.clear
            self.tableView.tableFooterView = loadingView
        }

        return sections
    }

    override func formFieldCell(_ formCell: OZLFormFieldCell, valueChangedFrom fromValue: AnyObject?, toValue: AnyObject?, atKeyPath keyPath: String, userInfo: [String : AnyObject]) {
        super.formFieldCell(formCell, valueChangedFrom:fromValue , toValue: toValue, atKeyPath: keyPath, userInfo: userInfo)
        let customField = userInfo[CustomFieldUserInfoKey] as? OZLModelCustomField

        if let toValue = toValue as? String {
            if keyPath == SubjectKeypath {
                self.issue.subject = toValue
            } else if keyPath == DescriptionKeypath {
                self.issue.issueDescription = toValue
            } else if keyPath == CommentKeypath {
                self.issue.setUpdateComment(toValue)
            } else if keyPath == TimeEstimationKeypath {
                if let toValue = Float(toValue) {
                    self.issue.estimatedHours = Float(toValue)
                }
            } else if keyPath == PercentCompleteKeypath {
                if let toValue = Float(toValue) {
                    self.issue.doneRatio = toValue
                }
            } else if let customField = customField {
                if let toValue = Float(toValue), customField.type == .float {
                    self.issue.setValueOnDiff(toValue as AnyObject, forCustomFieldId: customField.fieldId)
                } else if let toValue = Int(toValue), customField.type == .integer {
                    self.issue.setValueOnDiff(toValue as AnyObject, forCustomFieldId: customField.fieldId)
                } else {
                    assertionFailure("An unexpected custom field passed a raw string to valueChangedFrom:to:atKeyPath:userInfo:")
                }
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
        } else if let toValue = toValue as? OZLModelIssueCategory {
            if keyPath == CategoryKeypath {
                self.issue.category = toValue
            }
        } else if let toValue = toValue as? OZLModelVersion {
            if keyPath == TargetVersionKeypath {
                self.issue.targetVersion = toValue
            } else if let customField = customField {
                self.issue.setValueOnDiff(String(toValue.versionId) as AnyObject, forCustomFieldId: customField.fieldId)
            }
        } else if let toValue = toValue as? OZLModelUser {
            if keyPath == AssigneeKeypath {
                self.issue.assignedTo = toValue
            }
        } else if let toValue = toValue as? Date {
            if keyPath == DueDateKeypath {
                self.issue.dueDate = toValue
            } else if keyPath == StartDateKeypath {
                self.issue.startDate = toValue
//            } else if let customField = customField {
                // WARNING: Handle date formatting
//                self.issue.setValueOnDiff(<#T##value: String##String#>, forCustomFieldId: <#T##Int#>)
            }
        } else if let toValue = toValue as? OZLModelStringContainer, let value = toValue.value {
            if let customField = customField {
                self.issue.setValueOnDiff(value as AnyObject, forCustomFieldId: customField.fieldId)
            }
        }
        
        print("from: \(fromValue), to: \(toValue), keyPath: \(keyPath)")
    }

    func submitAction() {
        self.tableView.endEditing(true)

        print(self.issue.changeDictionary as Any)

        guard let hud = JGProgressHUD(style: .dark) else {
            return
        }

        hud.show(in: self.view)

        weak var weakSelf = self

        func completion(_ success: Bool, error: NSError?) {
            if let weakSelf = weakSelf {
                if success == false {
                    hud.indicatorView = JGProgressHUDImageIndicatorView(imageInLibraryBundleNamed: "jg_hud_error", enableTinting: true)
                    hud.dismiss(afterDelay: 1.5)
                } else {
                    hud.indicatorView = JGProgressHUDImageIndicatorView(imageInLibraryBundleNamed: "jg_hud_success", enableTinting: true)

                    weak var innerWeakSelf = weakSelf
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                        if let innerWeakSelf = innerWeakSelf {
                            innerWeakSelf.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            }
        }

        if self.editMode == .new {
            OZLNetwork.sharedInstance().createIssue(self.issue, withParams: [:], completion: completion as! (Bool, Error?) -> Void)
        } else if self.editMode == .existing {
            OZLNetwork.sharedInstance().update(self.issue, withParams: nil, completion: completion as! (Bool, Error?) -> Void)
        }
    }

    func dismissAction() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

private extension JGProgressHUDImageIndicatorView {
    convenience init(image: UIImage!, enableTinting: Bool) {
        var image: UIImage = image

        if enableTinting {
            image = image.withRenderingMode(.alwaysTemplate)
        }

        self.init(image: image)
    }

    convenience init(imageInLibraryBundleNamed name: String, enableTinting: Bool) {
        let bundle = Bundle(path: Bundle(for: JGProgressHUD.self).path(forResource: "JGProgressHUD Resources", ofType: "bundle")!)
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        self.init(image: image, enableTinting: enableTinting)
    }
}

private extension OZLModelCustomField {
    func createFormFieldForIssue(_ issue: OZLModelIssue) -> OZLFormField {
        let fieldName = self.name ?? ""
        let keyPath = "cf_\(self.fieldId)"

        var formField: OZLFormField!

        switch self.type {
        case .boolean:
            formField = OZLEnumerationFormField(
                keyPath: keyPath,
                placeholder: fieldName,
                currentValue: self.value == "0" ? "No" : self.value == "1" ? "Yes" : nil,
                possibleValues: [
                    OZLModelStringContainer(string: "", value: ""),
                    OZLModelStringContainer(string: "Yes", value: "1"),
                    OZLModelStringContainer(string: "No", value: "0")
                ]
            )
        case .date:
            formField = OZLDateFormField(keyPath: keyPath, placeholder: fieldName)
        case .float:
            formField = OZLTextFormField(keyPath: keyPath, placeholder: fieldName, currentValue: self.value)
        case .integer:
            formField = OZLTextFormField(keyPath: keyPath, placeholder: fieldName, currentValue: self.value)
        case .link:
            formField = OZLTextFormField(keyPath: keyPath, placeholder: fieldName)
        case .list:
            formField = OZLEnumerationFormField(keyPath: keyPath, placeholder: fieldName, currentValue: self.value, possibleRealmValues: self.options!)
        case .longText:
            formField = OZLTextViewFormField(keyPath: keyPath, placeholder: fieldName, currentValue: self.value)
        case .text:
            formField = OZLTextFormField(keyPath: keyPath, placeholder: fieldName, currentValue: self.value)
        case .user:
            formField = OZLTextFormField(keyPath: keyPath, placeholder: fieldName, currentValue: self.value)
        case .version:
            formField = OZLEnumerationFormField(keyPath: keyPath, placeholder: fieldName, currentValue: self.value, possibleRealmValues: self.options!)
        default:
//            assertionFailure()
            formField = OZLFormField(keyPath: "", placeholder: "")
        }

        formField.userInfo[CustomFieldUserInfoKey] = self

        return formField
    }
}
