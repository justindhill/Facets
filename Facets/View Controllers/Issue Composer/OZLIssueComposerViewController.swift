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
                OZLTextFormField(keyPath: "issue.tracker", placeholder: "Tracker", currentValue: "Bug"),
                OZLTextFormField(keyPath: "issue.subject", placeholder: "Subject"),
                OZLTextFormField(keyPath: "issue.description", placeholder: "Description")
            ])
        ]
    }
}
