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
    var projectId: Int = 0 {
        willSet(newValue) {
            if newValue != self.projectId {
                self.issues = []
            }
        }
    }
    
    private var explicitTitle: String?
    var title: String {
        get {
            if let explicitTitle = self.explicitTitle {
                return explicitTitle
            } else {
                return OZLModelProject(forPrimaryKey: self.projectId)?.name ?? ""
            }
        }
        
        set(newValue) {
            self.explicitTitle = newValue
        }
    }
    
    var sortAndFilterOptions: OZLSortAndFilterOptions = OZLSortAndFilterOptions() {
        willSet(newValue) {
            if newValue != self.sortAndFilterOptions {
                self.issues = []
            }
        }
    }
    
    let projects = OZLModelProject.allObjects()
    var issues = [Issue]()

    var shouldShowProjectSelector = false
    var shouldShowComposeButton = false
    
    var moreIssuesAvailable: Bool = false
    var isLoading: Bool = false
    
    func loadIssuesCompletion(completion: (error: NSError?) -> Void) {
        if self.isLoading {
            return
        }
        
        weak var weakSelf = self
        
        self.isLoading = true
        let params = self.sortAndFilterOptions.requestParameters()

        Jiramazing.instance.searchIssuesWithJQLString("project = MAPP") { (issues, total, error) in

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
        let params = self.sortAndFilterOptions.requestParameters()

        Jiramazing.instance.searchIssuesWithJQLString("project = MAPP", offset: self.issues.count) { (issues, total, error) in
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
    
    func processUpdatedIssue(issue: OZLModelIssue) {
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
    
    func quickAssignController(quickAssign: OZLQuickAssignViewController, didChangeAssigneeInIssue issue: OZLModelIssue, from: OZLModelUser?, to: OZLModelUser?) {
        self.processUpdatedIssue(issue)
    }
}
