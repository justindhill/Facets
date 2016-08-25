//
//  OZLQueriesIssueListViewModel.swift
//  Facets
//
//  Created by Justin Hill on 1/1/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit
import Jiramazing

@objc protocol OZLIssueListViewModelDelegate {
    func viewModelIssueListContentDidChange(viewModel: OZLIssueListViewModel)
}

@objc class OZLIssueListViewModel: NSObject, OZLQuickAssignDelegate {
    
    var queryId = 0
    
    weak var delegate: OZLIssueListViewModelDelegate?
    var project: Project? = OZLSingleton.sharedInstance().serverInfo.currentProject {
        willSet(newValue) {
            if newValue != self.project {
                self.issues = []
            }
        }
    }
    
    private var explicitTitle: String?
    var title: String {
        get {
            if let explicitTitle = self.explicitTitle {
                return explicitTitle
            }

            return self.project?.name ?? ""
        }
        
        set(newValue) {
            self.explicitTitle = newValue
        }
    }
    
    var projects = OZLSingleton.sharedInstance().serverInfo.projects
    var issues = [Issue]()

    var shouldShowProjectSelector = false
    var shouldShowComposeButton = false
    
    var moreIssuesAvailable: Bool = false
    var isLoading: Bool = false

    override init() {
        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(serverInfoDidChange(_:)), name: OZLServerSyncDidEndNotification, object: nil)
    }
    
    func loadIssuesCompletion(completion: (error: NSError?) -> Void) {
        if self.isLoading {
            return
        }
        
        weak var weakSelf = self
        
        self.isLoading = true

        Jiramazing.instance.searchIssuesWithJQLString("project = \(self.project?.key ?? "")", maxResults: 25) { (issues, total, error) in

            weakSelf?.isLoading = false
            
            if let error = error {
                completion(error: error)
                return
            }
            
            if let weakSelf = weakSelf, let issues = issues {
                weakSelf.issues = issues
                weakSelf.moreIssuesAvailable = (weakSelf.issues.count < total);
                completion(error: error)
            }
        }
    }
    
    func loadMoreIssuesCompletion(completion: (error: NSError?) -> Void) {
        if self.isLoading {
            return
        }

        weak var weakSelf = self
        
        self.isLoading = true

        Jiramazing.instance.searchIssuesWithJQLString("project = \(project?.key ?? "")", offset: self.issues.count, maxResults: 25) { (issues, total, error) in
            weakSelf?.isLoading = false
            
            if let error = error {
                completion(error: error)
                return
            }
            
            if let weakSelf = weakSelf, let issues = issues {
                weakSelf.issues.appendContentsOf(issues)
                weakSelf.moreIssuesAvailable = (weakSelf.issues.count < total);
                completion(error: error)
            }
        }
    }
    
    func processUpdatedIssue(issue: Issue) {
        // WARNING: Issues aren't being processed
//        let existingIndex = self.issues.indexOf { (issueElement) -> Bool in
//            return (issueElement.index == issue.index)
//        }
//        
//        if let existingIndex = existingIndex {
//            self.issues.replaceRange(existingIndex...existingIndex, with: [ issue ])
//        }
//        
//        self.delegate?.viewModelIssueListContentDidChange(self)
    }
    
    func quickAssignController(quickAssign: OZLQuickAssignViewController, didChangeAssigneeInIssue issue: Issue, from: User?, to: User?) {
        self.processUpdatedIssue(issue)
    }

    func serverInfoDidChange(notification: NSNotification) {
        self.projects = OZLSingleton.sharedInstance().serverInfo.projects
    }
}
