//
//  OZLQuickAssignViewController.swift
//  Facets
//
//  Created by Justin Hill on 12/24/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

@objc class OZLQuickAssignViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    let CellReuseIdentifier = "reuseIdentifier"
    var canonicalUsers: RLMResults?
    var filteredUsers: RLMResults?
    var issueModel: OZLModelIssue?
    
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func loadView() {
        self.view = OZLQuickAssignView(frame: CGRectMake(0, 0, 320, 568))
    }
    
    override func viewDidLoad() {
        if let view = self.view as? OZLQuickAssignView {
            self.preferredContentSize = CGSizeMake(320, 350)
            
            view.cancelButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
            view.backgroundColor = UIColor.whiteColor()
            
            view.tableView.dataSource = self
            view.tableView.delegate = self
            view.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:CellReuseIdentifier)
            
            view.filterField.delegate = self
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowOrHide:", name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowOrHide:", name: UIKeyboardWillHideNotification, object: nil)
    
            self.canonicalUsers = OZLModelUser.allObjects()
            self.filteredUsers = self.canonicalUsers
        }
    }
    
    func dismiss() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func keyboardWillShowOrHide(notification: NSNotification) {
        if let view = self.view as? OZLQuickAssignView {
            if let keyboardFrameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardFrame = keyboardFrameValue.CGRectValue()
            
                if notification.name == UIKeyboardWillShowNotification && view.filterField.isFirstResponder() {
                    let tableBottomOffset = view.frame.size.height - view.tableView.bottom
                    view.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrame.size.height - tableBottomOffset, 0)
                    self.preferredContentSize = CGSizeMake(320, 450)
                } else {
                    view.tableView.contentInset = UIEdgeInsetsZero
                    self.preferredContentSize = CGSizeMake(320, 350)
                }
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let users = self.filteredUsers {
            return Int(users.count)
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier, forIndexPath: indexPath)
        if let user = self.filteredUsers?[UInt(indexPath.row)] {
            cell.textLabel?.text = user.name
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let view = self.view as? OZLQuickAssignView, let issueModel = self.issueModel {
            if let newAssignee = self.filteredUsers?.objectAtIndex(UInt(indexPath.row)) as? OZLModelUser {
                issueModel.assignedTo = newAssignee
                view.showLoadingOverlay()
                
                weak var weakSelf = self
                
                OZLNetwork.sharedInstance().updateIssue(issueModel, withParams: nil, completion: { (success, error) -> Void in
                    view.hideLoadingOverlay()
                    
                    if error == nil {
                        weakSelf?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                        
                    } else {
                        let alert = UIAlertController(title: "Error", message: "Couldn't set assignee.", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                            weakSelf?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                        }))
                        
                        weakSelf?.presentViewController(alert, animated: true, completion: nil)
                    }
                })
            }
            
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
        } else if let view = self.view as? OZLQuickAssignView,
            let resultString = (textField.text as NSString?)?.stringByReplacingCharactersInRange(range, withString: string) {
                
            self.filteredUsers = self.canonicalUsers?.objectsWithPredicate(NSPredicate(format: "%K CONTAINS[c] %@", "name", resultString))
            view.tableView.reloadData()
        }
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if let view = self.view as? OZLQuickAssignView {
            self.filteredUsers = self.canonicalUsers
            view.tableView.reloadData()
        }
        
        return true
    }
}
