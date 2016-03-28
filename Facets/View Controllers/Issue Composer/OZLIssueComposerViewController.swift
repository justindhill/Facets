//
//  OZLIssueComposerViewController.swift
//  Facets
//
//  Created by Justin Hill on 12/6/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

class OZLIssueComposerViewController: OZLFormViewController {

    private let ProjectKeypath = "issue.project"
    private let TrackerKeypath = "issue.tracker"
    private let StatusKeypath = "issue.status"
    private let SubjectKeypath = "issue.subject"
    private let DescriptionKeypath = "issue.description"

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
            OZLFormSection(title: nil, fields: [
                OZLEnumerationFormField(keyPath: ProjectKeypath,
                    placeholder: "Project",
                    currentValue: self.changes[ProjectKeypath] as? RLMObject ?? self.currentProject,
                    possibleRealmValues: self.projects),

                OZLEnumerationFormField(
                    keyPath: TrackerKeypath,
                    placeholder: "Tracker",
                    currentValue: self.issue.tracker,
                    possibleRealmValues: self.currentProject.trackers),

                OZLEnumerationFormField(
                    keyPath: StatusKeypath,
                    placeholder: "Status",
                    currentValue: self.issue.status,
                    possibleRealmValues: self.issueStatuses),

                OZLTextFormField(
                    keyPath: SubjectKeypath,
                    placeholder: "Subject",
                    currentValue: self.issue.subject),

                OZLTextViewFormField(
                    keyPath: DescriptionKeypath,
                    placeholder: "Description",
                    currentValue: self.issue.description)
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
        }
        print("from: \(fromValue), to: \(toValue), keyPath: \(keyPath)")
    }

    func submitAction() {
        self.tableView.endEditing(true)

        print(self.issue.changeDictionary)

        if self.editMode == .New {
            OZLNetwork.sharedInstance().createIssue(self.issue, withParams: [:], completion: { (success, error) in
                print(error)
            })
        } else if self.editMode == .Existing {
            OZLNetwork.sharedInstance().updateIssue(self.issue, withParams: nil, completion: { (success, error) in
                print(error)
            })
        }
    }

    func dismissAction() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
