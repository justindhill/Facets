//
//  OZLQueriesIssueListViewModel.swift
//  Facets
//
//  Created by Justin Hill on 1/1/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

@objc protocol OZLIssueListViewModelDelegate {
    func viewModelIssueListContentDidChange(_ viewModel: OZLIssueListViewModel)
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
    
    fileprivate var explicitTitle: String?
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
    
    func loadIssuesCompletion(_ completion: @escaping (_ error: NSError?) -> Void) {
        if self.isLoading {
            return
        }
        
        weak var weakSelf = self
        
        self.isLoading = true
        let params = self.sortAndFilterOptions.requestParameters()
        OZLNetwork.sharedInstance().getIssueList(forQueryId: self.queryId, projectId: self.projectId, offset: 0, limit: 25, params: params) { (result, totalCount, error) -> Void in
            
            weakSelf?.isLoading = false
            
            if let error = error {
                completion(error as NSError?)
                return
            }
            
            if let weakSelf = weakSelf, let result = result as? Array<OZLModelIssue> {
                weakSelf.issues = result
                weakSelf.moreIssuesAvailable = (weakSelf.issues.count < totalCount);
                completion(error as NSError?)
            }
        }
    }
    
    func loadMoreIssuesCompletion(_ completion: @escaping (_ error: NSError?) -> Void) {
        if self.isLoading {
            return
        }
        
        weak var weakSelf = self
        
        self.isLoading = true
        let params = self.sortAndFilterOptions.requestParameters()
        OZLNetwork.sharedInstance().getIssueList(forQueryId: self.queryId, projectId: self.projectId, offset: self.issues.count, limit: 25, params: params) { (result, totalCount, error) -> Void in
            
            weakSelf?.isLoading = false
            
            if let error = error {
                completion(error as NSError?)
                return
            }
            
            if let weakSelf = weakSelf, let result = result as? Array<OZLModelIssue> {
                weakSelf.issues.append(contentsOf: result)
                weakSelf.moreIssuesAvailable = (weakSelf.issues.count < totalCount);
                completion(error as NSError?)
            }
        }
    }
    
    func processUpdatedIssue(_ issue: OZLModelIssue) {
        let existingIndex = self.issues.index { (issueElement) -> Bool in
            return (issueElement.index == issue.index)
        }
        
        if let existingIndex = existingIndex {
            self.issues.replaceSubrange(existingIndex...existingIndex, with: [ issue ])
        }
        
        self.delegate?.viewModelIssueListContentDidChange(self)
    }
    
    func quickAssignController(_ quickAssign: OZLQuickAssignViewController, didChangeAssigneeInIssue issue: OZLModelIssue, from: OZLModelUser?, to: OZLModelUser?) {
        self.processUpdatedIssue(issue)
    }
}
