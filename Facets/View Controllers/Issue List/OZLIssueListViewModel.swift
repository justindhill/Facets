//
//  OZLQueriesIssueListViewModel.swift
//  Facets
//
//  Created by Justin Hill on 1/1/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

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
    var issues: Array<OZLModelIssue> = []

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
        OZLNetwork.sharedInstance().getIssueListForQueryId(self.queryId, projectId: self.projectId, offset: 0, limit: 25, params: params) { (result, totalCount, error) -> Void in
            
            weakSelf?.isLoading = false
            
            if let error = error {
                completion(error: error)
                return
            }
            
            if let weakSelf = weakSelf, let result = result as? Array<OZLModelIssue> {
                weakSelf.issues = result
                weakSelf.moreIssuesAvailable = (weakSelf.issues.count < totalCount);
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
        OZLNetwork.sharedInstance().getIssueListForQueryId(self.queryId, projectId: self.projectId, offset: self.issues.count, limit: 25, params: params) { (result, totalCount, error) -> Void in
            
            weakSelf?.isLoading = false
            
            if let error = error {
                completion(error: error)
                return
            }
            
            if let weakSelf = weakSelf, let result = result as? Array<OZLModelIssue> {
                weakSelf.issues.appendContentsOf(result)
                weakSelf.moreIssuesAvailable = (weakSelf.issues.count < totalCount);
                completion(error: error)
            }
        }
    }
    
    func processUpdatedIssue(issue: OZLModelIssue) {
        let existingIndex = self.issues.indexOf { (issueElement) -> Bool in
            return (issueElement.index == issue.index)
        }
        
        if let existingIndex = existingIndex {
            self.issues.replaceRange(existingIndex...existingIndex, with: [ issue ])
        }
        
        self.delegate?.viewModelIssueListContentDidChange(self)
    }
    
    func quickAssignController(quickAssign: OZLQuickAssignViewController, didChangeAssigneeInIssue issue: OZLModelIssue, from: OZLModelUser?, to: OZLModelUser?) {
        self.processUpdatedIssue(issue)
    }
}
