//
//  OZLProjectInfoManager.swift
//  Facets
//
//  Created by Justin Hill on 8/21/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import Foundation
import Jiramazing

@objc enum OZLProjectInfoManagerError: NSInteger {
    case UnexpectedNilResult
}

@objc class OZLProjectInfoManager: NSObject {
    static let ErrorDomain = "OZLProjectInfoManagerErrorDomain"

    private let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true).first
    private var projectsPath: String = ""
    var allProjectStubs: [Project]
    private(set) var currentProject: Project? = nil

    override init() {
        if let documentsDirectory = self.documentsDirectory {
            self.projectsPath = (documentsDirectory as NSString).stringByAppendingPathComponent("projects.plist")

            if let projects = NSKeyedUnarchiver.unarchiveObjectWithFile(self.projectsPath) as? [Project] {
                self.allProjectStubs = projects
            } else {
                self.allProjectStubs = []
            }
        } else {
            self.allProjectStubs = []
        }

        super.init()
    }

    func updateProjectStubs(completion: (error: NSError?) -> Void) {
        Jiramazing.instance.getProjects { (projects, error) in
            if let error = error {
                completion(error: error)
                return
            }

            if let projects = projects {
                self.allProjectStubs = projects;
                completion(error: nil)
                return
            }

            completion(error: NSError(
                domain: OZLProjectInfoManager.ErrorDomain,
                code: OZLProjectInfoManagerError.UnexpectedNilResult.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "The project list is not available."]
                )
            )
        }
    }

    func setCurrentProject(projectKey: String, completion: (error: NSError) -> Void) {

    }
}