////
////  OZLIssueComposerViewController.swift
////  Facets
////
////  Created by Justin Hill on 12/6/15.
////  Copyright © 2015 Justin Hill. All rights reserved.
////
//
//import UIKit
//import JGProgressHUD
//import Jiramazing
//
//private let CustomFieldUserInfoKey = "custom-field"
//
//class OZLIssueComposerViewController: OZLFormViewController {
//
//    private let ProjectKeypath = "issue.project"
//    private let TrackerKeypath = "issue.tracker"
//    private let StatusKeypath = "issue.status"
//    private let SubjectKeypath = "issue.subject"
//    private let DescriptionKeypath = "issue.description"
//    private let StartDateKeypath = "issue.start-date"
//    private let DueDateKeypath = "issue.due-date"
//    private let CommentKeypath = "issue.update-comment"
//    private let TargetVersionKeypath = "issue.target-version"
//    private let CategoryKeypath = "issue.category"
//    private let AssigneeKeypath = "issue.assignee"
//    private let TimeEstimationKeypath = "issue.estimated-time"
//    private let PercentCompleteKeypath = "issue.percent-complete"
//
//    private enum EditMode {
//        case New
//        case Existing
//    }
//
//    var currentProject: Project
//    var projects = [Project]()
//    var versions = [Version]()
//    var categories = [IssueType]()
//    var issueStatuses = [StatusCategory]()
//    var users = [User]()
//    private var editMode: EditMode
//
//    @NSCopying var issue: Issue
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if let id = self.issue.id {
//            self.title = "\(self.issue.issueType?.name ?? "") #\(id)"
//        } else {
//            self.title = "New Issue"
//        }
//
//        self.refreshCustomFields()
//
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: #selector(submitAction))
//    }
//
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//
//        if self.presentingViewController != nil {
//            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(dismissAction))
//        }
//    }
//
//    init(currentProjectID: Int) {
//        guard let project = OZLModelProject(forPrimaryKey: currentProjectID) else {
//            fatalError("Tried to instantiate an issue composer without a project.")
//        }
//
//        self.currentProject = project
//        self.editMode = .New
//        self.issue = OZLModelIssue()
//        self.issue.modelDiffingEnabled = true
//
//        super.init(style: .Grouped)
//
//        self.issue.projectId = project.projectId
//        self.issue.tracker = project.trackers.firstObject() as? OZLModelTracker
//        self.issue.status = self.issueStatuses.firstObject() as? OZLModelIssueStatus
//    }
//
//    init(issue: OZLModelIssue) {
//        guard let project = OZLModelProject(forPrimaryKey: issue.projectId) else {
//            fatalError("Project ID associated with passed issue is invalid")
//        }
//
//        self.issue = issue
//        self.issue.modelDiffingEnabled = true
//
//        self.currentProject = project
//        self.editMode = .Existing
//
//        super.init(style: .Grouped)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func definitionsForFields() -> [OZLFormSection] {
//
//        var sections = [OZLFormSection]()
//
//        if self.editMode == .Existing {
//            sections.append(OZLFormSection(
//                title: "Update comment",
//                fields: [
//                    OZLTextViewFormField(keyPath: CommentKeypath, placeholder: "Comment", currentValue: nil)
//                ]))
//        }
//
//        let generalSection = OZLFormSection(title: "General", fields: [
//            OZLEnumerationFormField(keyPath: ProjectKeypath,
//                placeholder: "Project",
//                currentValue: (self.changes[ProjectKeypath] as? OZLEnumerationFormFieldValue)?.stringValue() ?? self.currentProject.name,
//                possibleRealmValues: self.projects),
//
//            OZLEnumerationFormField(
//                keyPath: TrackerKeypath,
//                placeholder: "Tracker",
//                currentValue: (self.changes[TrackerKeypath] as? OZLEnumerationFormFieldValue)?.stringValue() ?? self.issue.tracker?.name,
//                possibleRealmValues: self.currentProject.trackers),
//
//            OZLEnumerationFormField(
//                keyPath: StatusKeypath,
//                placeholder: "Status",
//                currentValue: (self.changes[StatusKeypath] as? OZLEnumerationFormFieldValue)?.stringValue() ?? self.issue.status?.name,
//                possibleRealmValues: self.issueStatuses),
//
//            OZLEnumerationFormField(
//                keyPath: CategoryKeypath,
//                placeholder: "Category",
//                currentValue: (self.changes[CategoryKeypath] as? OZLEnumerationFormFieldValue)?.stringValue() ?? self.issue.category?.name,
//                possibleRealmValues: self.categories),
//
//            OZLEnumerationFormField(
//                keyPath: AssigneeKeypath,
//                placeholder: "Assignee",
//                currentValue: (self.changes[AssigneeKeypath] as? OZLEnumerationFormFieldValue)?.stringValue() ?? self.issue.assignedTo?.name,
//                possibleRealmValues: self.users),
//
//            OZLTextFormField(
//                keyPath: SubjectKeypath,
//                placeholder: "Subject",
//                currentValue: self.changes[SubjectKeypath] as? String ?? self.issue.subject),
//
//            OZLTextViewFormField(
//                keyPath: DescriptionKeypath,
//                placeholder: "Description",
//                currentValue: self.changes[DescriptionKeypath] as? String ?? self.issue.issueDescription)
//        ])
//
//        sections.append(generalSection)
//
//        let schedulingSection = OZLFormSection(title: "Scheduling", fields: [
//            OZLEnumerationFormField(
//                keyPath: TargetVersionKeypath,
//                placeholder: "Target version",
//                currentValue: (self.changes[TargetVersionKeypath] as? OZLEnumerationFormFieldValue)?.stringValue() ?? self.issue.targetVersion?.name,
//                possibleRealmValues: self.versions),
//
//            OZLTextFormField(
//                keyPath: TimeEstimationKeypath,
//                placeholder: "Estimated time",
//                currentValue: (self.changes[TimeEstimationKeypath] as? String) ?? String(self.issue.estimatedHours)),
//
//            OZLTextFormField(
//                keyPath: PercentCompleteKeypath,
//                placeholder: "Percent complete",
//                currentValue: (self.changes[PercentCompleteKeypath] as? String ?? String(self.issue.doneRatio))),
//
//            OZLDateFormField(
//                keyPath: StartDateKeypath,
//                placeholder: "Start date",
//                currentValue: self.changes[StartDateKeypath] as? NSDate ?? self.issue.startDate),
//
//            OZLDateFormField(
//                keyPath: DueDateKeypath,
//                placeholder: "Due date",
//                currentValue: self.changes[DueDateKeypath] as? NSDate ?? self.issue.dueDate)
//        ])
//
//        sections.append(schedulingSection)
//
//        if let customFields = self.customFields where customFields.count > 0 {
//            var fields = [OZLFormField]()
//
//            for field in customFields {
//                fields.append(field.createFormFieldForIssue(self.issue))
//            }
//
//            sections.append(OZLFormSection(title: "Custom Fields", fields: fields))
//            self.tableView.tableFooterView = nil
//        } else {
//            let loadingView = OZLLoadingView(frame: CGRectMake(0, 0, 320, 44))
//            loadingView.startLoading()
//            loadingView.backgroundColor = UIColor.clearColor()
//            self.tableView.tableFooterView = loadingView
//        }
//
//        return sections
//    }
//
//    override func formFieldCell(formCell: OZLFormFieldCell, valueChangedFrom fromValue: AnyObject?, toValue: AnyObject?, atKeyPath keyPath: String, userInfo: [String : AnyObject]) {
//        super.formFieldCell(formCell, valueChangedFrom:fromValue , toValue: toValue, atKeyPath: keyPath, userInfo: userInfo)
//        let customField = userInfo[CustomFieldUserInfoKey] as? OZLModelCustomField
//
//        if let toValue = toValue as? String {
//            if keyPath == SubjectKeypath {
//                self.issue.subject = toValue
//            } else if keyPath == DescriptionKeypath {
//                self.issue.issueDescription = toValue
//            } else if keyPath == CommentKeypath {
//                self.issue.setUpdateComment(toValue)
//            } else if keyPath == TimeEstimationKeypath {
//                if let toValue = Float(toValue) {
//                    self.issue.estimatedHours = Float(toValue)
//                }
//            } else if keyPath == PercentCompleteKeypath {
//                if let toValue = Float(toValue) {
//                    self.issue.doneRatio = toValue
//                }
//            } else if let customField = customField {
//                if let toValue = Float(toValue) where customField.type == .Float {
//                    self.issue.setValueOnDiff(toValue, forCustomFieldId: customField.fieldId)
//                } else if let toValue = Int(toValue) where customField.type == .Integer {
//                    self.issue.setValueOnDiff(toValue, forCustomFieldId: customField.fieldId)
//                } else {
//                    assertionFailure("An unexpected custom field passed a raw string to valueChangedFrom:to:atKeyPath:userInfo:")
//                }
//            }
//
//        } else if let toValue = toValue as? OZLModelTracker {
//            if keyPath == TrackerKeypath {
//                self.issue.tracker = toValue
//            }
//
//        } else if let toValue = toValue as? OZLModelProject {
//            if keyPath == ProjectKeypath {
//                self.issue.projectId = toValue.projectId
//            }
//        } else if let toValue = toValue as? OZLModelIssueStatus {
//            if keyPath == StatusKeypath {
//                self.issue.status = toValue
//            }
//        } else if let toValue = toValue as? OZLModelIssueCategory {
//            if keyPath == CategoryKeypath {
//                self.issue.category = toValue
//            }
//        } else if let toValue = toValue as? OZLModelVersion {
//            if keyPath == TargetVersionKeypath {
//                self.issue.targetVersion = toValue
//            } else if let customField = customField {
//                self.issue.setValueOnDiff(String(toValue.versionId), forCustomFieldId: customField.fieldId)
//            }
//        } else if let toValue = toValue as? OZLModelUser {
//            if keyPath == AssigneeKeypath {
//                self.issue.assignedTo = toValue
//            }
//        } else if let toValue = toValue as? NSDate {
//            if keyPath == DueDateKeypath {
//                self.issue.dueDate = toValue
//            } else if keyPath == StartDateKeypath {
//                self.issue.startDate = toValue
//            } else if let customField = customField {
//                // WARNING: Handle date formatting
////                self.issue.setValueOnDiff(<#T##value: String##String#>, forCustomFieldId: <#T##Int#>)
//            }
//        } else if let toValue = toValue as? OZLModelStringContainer, value = toValue.value {
//            if let customField = customField {
//                self.issue.setValueOnDiff(value, forCustomFieldId: customField.fieldId)
//            }
//        }
//        
//        print("from: \(fromValue), to: \(toValue), keyPath: \(keyPath)")
//    }
//
//    func submitAction() {
//        self.tableView.endEditing(true)
//
//        print(self.issue.changeDictionary)
//
//        let hud = JGProgressHUD(style: .Dark)
//        hud.showInView(self.view)
//
//        weak var weakSelf = self
//
//        func completion(success: Bool, error: NSError?) {
//            if let weakSelf = weakSelf {
//                if success == false {
//                    hud.indicatorView = JGProgressHUDImageIndicatorView(imageInLibraryBundleNamed: "jg_hud_error", enableTinting: true)
//                    hud.dismissAfterDelay(1.5)
//                } else {
//                    hud.indicatorView = JGProgressHUDImageIndicatorView(imageInLibraryBundleNamed: "jg_hud_success", enableTinting: true)
//
//                    weak var innerWeakSelf = weakSelf
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
//                        if let innerWeakSelf = innerWeakSelf {
//                            innerWeakSelf.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
//                        }
//                    })
//                }
//            }
//        }
//
//        // WARNING: Create or update issue
////        if self.editMode == .New {
////            OZLNetwork.sharedInstance().createIssue(self.issue, withParams: [:], completion: completion)
////        } else if self.editMode == .Existing {
////            OZLNetwork.sharedInstance().updateIssue(self.issue, withParams: nil, completion: completion)
////        }
//    }
//
//    func dismissAction() {
//        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
//    }
//}
//
//private extension JGProgressHUDImageIndicatorView {
//    convenience init(image: UIImage!, enableTinting: Bool) {
//        var image: UIImage = image
//
//        if enableTinting {
//            image = image.imageWithRenderingMode(.AlwaysTemplate)
//        }
//
//        self.init(image: image)
//    }
//
//    convenience init(imageInLibraryBundleNamed name: String, enableTinting: Bool) {
//        let bundle = NSBundle(path: NSBundle(forClass: JGProgressHUD.self).pathForResource("JGProgressHUD Resources", ofType: "bundle")!)
//        let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
//        self.init(image: image, enableTinting: enableTinting)
//    }
//}
