//
//  OZLQuickAssignViewController.swift
//  Facets
//
//  Created by Justin Hill on 12/24/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

@objc protocol OZLQuickAssignDelegate {
    func quickAssignController(_ quickAssign: OZLQuickAssignViewController, didChangeAssigneeInIssue issue: OZLModelIssue, from: OZLModelUser?, to: OZLModelUser?)
}

@objc class OZLQuickAssignViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    let CellReuseIdentifier = "reuseIdentifier"
    var canonicalMemberships: RLMResults<RLMObject>?
    var filteredMemberships: RLMResults<RLMObject>?
    var issueModel: OZLModelIssue?
    weak var delegate: OZLQuickAssignDelegate?
    
    convenience init(issueModel: OZLModelIssue) {
        self.init(nibName: nil, bundle: nil)
        self.issueModel = issueModel
        
        // Reset the change dictionary in case it has already been modified
        self.issueModel?.modelDiffingEnabled = false
        self.issueModel?.modelDiffingEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func loadView() {
        self.view = OZLQuickAssignView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
    }
    
    override func viewDidLoad() {
        if let view = self.view as? OZLQuickAssignView {
            if self.popoverPresentationController?.sourceView == nil {
                self.preferredContentSize = CGSize(width: 320, height: 350)
            }
            
            view.cancelButton.addTarget(self, action: #selector(dismissQuickAssignView), for: .touchUpInside)
            view.backgroundColor = UIColor.white
            
            view.tableView.dataSource = self
            view.tableView.delegate = self
            view.tableView.register(UITableViewCell.self, forCellReuseIdentifier:CellReuseIdentifier)
            
            view.filterField.delegate = self
            
            NotificationCenter.default.addObserver(self, selector: #selector(OZLQuickAssignViewController.keyboardWillShowOrHide(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(OZLQuickAssignViewController.keyboardWillShowOrHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
            guard let issueModel = self.issueModel, let projectId = issueModel.projectId else {
                assertionFailure("Issue model wasn't set on OZLQuickAssignViewController before its view was loaded.");
                return
            }
            
            self.canonicalMemberships = OZLModelMembership.objects(with: NSPredicate(format: "%K = %ld", "projectId", projectId))
            self.filteredMemberships = self.canonicalMemberships
        }
    }
    
    @objc func dismissQuickAssignView() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShowOrHide(_ notification: Notification) {
        if let view = self.view as? OZLQuickAssignView {
            if let keyboardFrameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardFrame = keyboardFrameValue.cgRectValue
            
                if notification.name == NSNotification.Name.UIKeyboardWillShow && view.filterField.isFirstResponder {
                    let tableBottomOffset = view.frame.size.height - view.tableView.bottom
                    view.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrame.size.height - tableBottomOffset, 0)

                    if self.popoverPresentationController?.sourceView == nil {
                        self.preferredContentSize = CGSize(width: 320, height: 450)
                    }
                } else {
                    view.tableView.contentInset = UIEdgeInsets.zero

                    if self.popoverPresentationController?.sourceView == nil {
                        self.preferredContentSize = CGSize(width: 320, height: 350)
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let memberships = self.filteredMemberships {
            return Int(memberships.count)
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier, for: indexPath)
        if let membership = self.filteredMemberships?[UInt(indexPath.row)] as? OZLModelMembership {
            cell.textLabel?.text = membership.user.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let view = self.view as? OZLQuickAssignView, let issueModel = self.issueModel {
            if let newAssignee = self.filteredMemberships?.object(at: UInt(indexPath.row)) as? OZLModelMembership {
                let oldAssignee = issueModel.assignedTo
                issueModel.assignedTo = newAssignee.user
                view.showLoadingOverlay()
                
                weak var weakSelf = self
                
                OZLNetwork.sharedInstance().update(issueModel, withParams: nil, completion: { (success, error) -> Void in
                    view.hideLoadingOverlay()
                    
                    if let weakSelf = weakSelf, error == nil {
                        weakSelf.presentingViewController?.dismiss(animated: true, completion: nil)
                        weakSelf.delegate?.quickAssignController(weakSelf, didChangeAssigneeInIssue: issueModel, from: oldAssignee, to: newAssignee.user)
                        
                    } else {
                        let alert = UIAlertController(title: "Error", message: "Couldn't set assignee.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                            weakSelf?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }))
                        
                        weakSelf?.present(alert, animated: true, completion: nil)
                    }
                })
            }
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
        } else if let view = self.view as? OZLQuickAssignView,
            let resultString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
                
            self.filteredMemberships = self.canonicalMemberships?.objects(with: NSPredicate(format: "%K CONTAINS[c] %@", "user.name", resultString))
            view.tableView.reloadData()
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let view = self.view as? OZLQuickAssignView {
            self.filteredMemberships = self.canonicalMemberships
            view.tableView.reloadData()
        }
        
        return true
    }
}
