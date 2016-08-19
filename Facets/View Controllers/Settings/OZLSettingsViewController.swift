//
//  OZLSettingsViewController.swift
//  Facets
//
//  Created by Justin Hill on 6/9/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit
import JGProgressHUD

class OZLSettingsViewController: OZLFormViewController {

    private let ServerURLKeypath = "credentials.server"
    private let UsernameKeypath = "credentials.username"
    private let PasswordKeypath = "credentials.password"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"
    }

    override func definitionsForFields() -> [OZLFormSection] {
        var sections = [
            OZLFormSection(title: "Credentials", fields: [
                OZLTextFormField(keyPath: ServerURLKeypath, placeholder: "Redmine URL", currentValue: OZLSingleton.sharedInstance().redmineHomeURL),
                OZLTextFormField(keyPath: UsernameKeypath, placeholder: "Username", currentValue: OZLSingleton.sharedInstance().redmineUserName),
                OZLTextFormField(keyPath: PasswordKeypath, placeholder: "Password", currentValue: OZLSingleton.sharedInstance().redminePassword)
            ]),
        ]

        if OZLThirdPartyIntegrations.Enabled {
            sections.append(OZLFormSection(title: "Support", fields: [
                OZLButtonFormField(keyPath: "", title: "FAQ", target: self, action: #selector(faqAction(_:))),
                OZLButtonFormField(keyPath: "", title: "Contact us", target: self, action: #selector(contactUsAction(_:)))
            ]))
        }

        sections.append(OZLFormSection(title: "About", fields: [
            OZLInfoFormField(keyPath: "", placeholder: "Version", valueText: NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String),
            OZLInfoFormField(keyPath: "", placeholder: "Build Number", valueText: NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String),
            OZLButtonFormField(keyPath: "", title: "GitHub", target: self, action: #selector(githubAction(_:)))
        ]))

        return sections
    }

    override func formFieldCell(formCell: OZLFormFieldCell, valueChangedFrom fromValue: AnyObject?, toValue: AnyObject?, atKeyPath: String, userInfo: [String : AnyObject]) {
    }

    // MARK: Button actions
    func faqAction(sender: UIButton) {
        HelpshiftSupport.showFAQs(self, withOptions: nil)
    }

    func contactUsAction(sender: UIButton) {
        HelpshiftSupport.showConversation(self, withOptions: nil)
    }

    func githubAction(sender: UIButton) {
        if let url = NSURL(string: "https://github.com/justindhill/facets") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
