//
//  OZLIssueComposerViewController.swift
//  Facets
//
//  Created by Justin Hill on 12/6/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

class OZLIssueComposerViewController: OZLFormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Issue"
    }

    override func definitionsForFields() -> [OZLFormSection] {
        return [
            OZLFormSection(title: nil, fields: [
                OZLTextFormField(keyPath: "issue.project", placeholder: "Project", currentValue: "Universal App"),
                OZLEnumerationFormField(
                    keyPath: "issue.tracker",
                    placeholder: "Tracker",
                    currentValue: nil,
                    possibleValues: ["Bug", "Task", "Improvement"]),

                OZLTextFormField(keyPath: "issue.subject", placeholder: "Subject"),
                OZLTextViewFormField(keyPath: "issue.description", placeholder: "Description")
            ])
        ]
    }

    override func fieldValueChangedFrom(fromValue: AnyObject?, toValue: AnyObject?, atKeyPath keyPath: String) {
        print("from: \(fromValue), to: \(toValue), keyPath: \(keyPath)")
    }
}
