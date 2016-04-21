//
//  OZLIssueComposerViewController.swift
//  Facets
//
//  Created by Justin Hill on 12/6/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit
import JGProgressHUD

class OZLIssueComposerViewController: OZLFormViewController {

    private let ProjectKeypath = "issue.project"
    private let TrackerKeypath = "issue.tracker"
    private let StatusKeypath = "issue.status"
    private let SubjectKeypath = "issue.subject"
    private let DescriptionKeypath = "issue.description"
    private let StartDateKeypath = "issue.start-date"
    private let DueDateKeypath = "issue.due-date"

    private enum EditMode {
        case New
        case Existing
    }

    var currentProject: OZLModelProject
    var projects = OZLModelProject.allObjects()
    var issueStatuses = OZLModelIssueStatus.allObjects()
    @NSCopying var issue: OZLModelIssue
    private var editMode: EditMode

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Issue"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: #selector(submitAction))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if self.presentingViewController != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(dismissAction))
        }
    }

    func refreshPossibleValues() {

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

        return [
            OZLFormSection(title: "General", fields: [
                OZLEnumerationFormField(keyPath: ProjectKeypath,
                    placeholder: "Project",
                    currentValue: self.changes[ProjectKeypath] as? RLMObject ?? self.currentProject,
                    possibleRealmValues: self.projects),

                OZLEnumerationFormField(
                    keyPath: TrackerKeypath,
                    placeholder: "Tracker",
                    currentValue: self.changes[TrackerKeypath] as? RLMObject ?? self.issue.tracker,
                    possibleRealmValues: self.currentProject.trackers),

                OZLTextFormField(
                    keyPath: SubjectKeypath,
                    placeholder: "Subject",
                    currentValue: self.changes[SubjectKeypath] as? String ?? self.issue.subject),

                OZLTextViewFormField(
                    keyPath: DescriptionKeypath,
                    placeholder: "Description",
                    currentValue: self.changes[DescriptionKeypath] as? String ?? self.issue.description),

                OZLEnumerationFormField(
                    keyPath: StatusKeypath,
                    placeholder: "Status",
                    currentValue: self.changes[StatusKeypath] as? RLMObject ?? self.issue.status,
                    possibleRealmValues: self.issueStatuses)
            ]),

            OZLFormSection(title: "Scheduling", fields: [
                OZLDateFormField(
                    keyPath: StartDateKeypath,
                    placeholder: "Start date",
                    currentValue: self.changes[StartDateKeypath] as? NSDate ?? self.issue.startDate),

                OZLDateFormField(
                    keyPath: DueDateKeypath,
                    placeholder: "Due date",
                    currentValue: self.changes[DueDateKeypath] as? NSDate ?? self.issue.dueDate)
            ])
        ]
    }

    override func formFieldCell(formCell: OZLFormFieldCell, valueChangedFrom fromValue: AnyObject?, toValue: AnyObject?, atKeyPath keyPath: String, userInfo: [String : AnyObject]) {
        super.formFieldCell(formCell, valueChangedFrom:fromValue , toValue: toValue, atKeyPath: keyPath, userInfo: userInfo)

        if let toValue = toValue as? String {
            if keyPath == SubjectKeypath {
                self.issue.subject = toValue
            } else if keyPath == DescriptionKeypath {
                self.issue.description = toValue
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

extension JGProgressHUDImageIndicatorView {
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
