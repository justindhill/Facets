//
//  OZLIssueListViewController.swift
//  Facets
//
//  Created by Justin Hill on 1/2/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLIssueListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, OZLIssueListViewModelDelegate, UIViewControllerPreviewingDelegate, OZLSortAndFilterViewControllerDelegate, OZLNavigationChildChangeListener {
    
    private let IssueListComposeButtonHeight: CGFloat = 48.0
    private let ZeroHeightFooterTag = -1
    
    private let IssueCellReuseIdentifier = "IssueCellReuseIdentifier"
    
    private var isFirstAppearance = true
    private var composeButton: UIButton?
    private var searchController: UISearchController?
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: OZLIssueListViewModel! {
        willSet(newValue) {
            newValue?.delegate = self
        }
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel?.projectId = OZLSingleton.sharedInstance().currentProjectID
        self.title = self.viewModel?.title
        
        if self.isFirstAppearance {
            self.refreshProjectSelector()
            self.view.tintColor = self.parentViewController?.view.tintColor
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-filter"), style: .Done, target: self, action: "filterAction:")
            
            self.showFooterActivityIndicator()
            self.reloadProjectData()
        }
        
        if self.viewModel.shouldShowProjectSearch && self.searchController == nil {
            
            let resultsController = OZLIssueListViewController()
            resultsController.viewModel = OZLIssueListViewModel()
            resultsController.extendedLayoutIncludesOpaqueBars = true
            
            self.searchController = OZLSearchController(searchResultsController: resultsController)
            self.searchController!.searchBar.placeholder = "Search Project"
            self.searchController!.searchBar.searchBarStyle = .Minimal
            self.searchController!.searchBar.backgroundColor = UIColor.whiteColor()
            
            
            if #available(iOS 9.1, *) {
                self.searchController!.obscuresBackgroundDuringPresentation = true
            } else {
                self.searchController?.dimsBackgroundDuringPresentation = true
            }
            
            self.tableView.tableHeaderView = self.searchController?.searchBar
        }
        
        if self.viewModel.shouldShowComposeButton && self.composeButton?.superview == nil {
            self.composeButton = UIButton(type: .System)
            self.composeButton!.backgroundColor = self.view.tintColor;
            self.composeButton!.tintColor = UIColor.whiteColor()
            self.composeButton!.setImage(UIImage(named: "icon-plus"), forState:.Normal)
            self.composeButton!.titleLabel?.font = UIFont.systemFontOfSize(28)
            self.composeButton!.contentHorizontalAlignment = .Center
            self.composeButton!.contentVerticalAlignment = .Center
            
            self.composeButton!.layer.shadowColor = UIColor.blackColor().CGColor
            self.composeButton!.layer.shadowOpacity = 0.2
            self.composeButton!.layer.shadowOffset = CGSizeMake(0.0, 2.0)
            
            self.composeButton!.frame = CGRectMake(0, 0, self.IssueListComposeButtonHeight, self.IssueListComposeButtonHeight)
            self.composeButton!.layer.cornerRadius = 24.0
            self.composeButton!.addTarget(self, action: "composeButtonAction:", forControlEvents:.TouchUpInside)
            self.view.addSubview(self.composeButton!)
            
        } else if !self.viewModel.shouldShowComposeButton && self.composeButton?.superview != nil {
            self.composeButton?.removeFromSuperview()
            self.composeButton = nil
        }
        
        if let selectedIndexPaths = self.tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 9.0, *) {
            if self.traitCollection.forceTouchCapability == .Available {
                self.registerForPreviewingWithDelegate(self, sourceView: self.view)
            }
        }
        
        if !self.isFirstAppearance {
            self.refreshProjectSelector()
        }
        
        self.isFirstAppearance = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let composeButton = self.composeButton {
            let newOrigin = CGPointMake(self.view.frame.size.width - OZLContentPadding - composeButton.frame.size.width,
                self.view.frame.size.height - OZLContentPadding - composeButton.frame.size.height - self.bottomLayoutGuide.length);
            
            self.composeButton?.frame.origin = newOrigin
        }
    }
    
    // MARK: - Button actions
    func filterAction(sender: UIButton?) {
        let sortAndFilter = OZLSortAndFilterViewController()
        sortAndFilter.delegate = self
        sortAndFilter.options = self.viewModel.sortAndFilterOptions
        
        let nav = UINavigationController(rootViewController: sortAndFilter)
        nav.modalPresentationStyle = .FormSheet
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func composeButtonAction(sender: UIButton?) {
        let composer = OZLIssueComposerViewController()
        composer.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismissComposerAction:")
        
        let nav = UINavigationController(rootViewController: composer)
        nav.modalPresentationStyle = .FormSheet
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func dismissComposerAction(sender: UIButton?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Project selector
    func didSelectProjectAtIndex(index: Int) {
        
        if let project = viewModel.projects[UInt(index)] as? OZLModelProject where viewModel.projectId != project.projectId {
            self.showFooterActivityIndicator()
            OZLSingleton.sharedInstance().currentProjectID = project.projectId
            viewModel.projectId = project.projectId
            
            self.tableView.reloadData()
            self.reloadProjectData()
        }
    }
    
    // MARK: - OZLSortAndFilterViewControllerDelegate
    func sortAndFilter(sortAndFilter: OZLSortAndFilterViewController, shouldDismissWithNewOptions newOptions: OZLSortAndFilterOptions?) {
        if let newOptions = newOptions where self.viewModel.sortAndFilterOptions != newOptions {
            self.viewModel!.sortAndFilterOptions = newOptions
            self.tableView.reloadData()
            self.showFooterActivityIndicator()
            self.reloadProjectData()
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - OZLNavigationChildChangeListener
    func navigationChild(navigationChild: UIViewController!, didModifyIssue issue: OZLModelIssue!) {
        self.viewModel.processUpdatedIssue(issue)
    }
    
    // MARK: - OZLIssueListViewModelDelegate
    func viewModelIssueListContentDidChange(viewModel: OZLIssueListViewModel) {
        self.tableView.reloadData()
    }
    
    // MARK: - Previewing
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let translatedPoint = CGPointMake(location.x, self.tableView.contentOffset.y + location.y)
        let indexPath = self.tableView.indexPathForRowAtPoint(translatedPoint)
        
        if let indexPath = indexPath {
            let issue = self.viewModel.issues[indexPath.row]
            let viewModel = OZLIssueViewModel(issueModel: issue)
            
            let issueVC = OZLIssueViewController()
            issueVC.viewModel = viewModel
            issueVC.previewQuickAssignDelegate = self.viewModel
            
            return issueVC
        }
        
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        self.showViewController(viewControllerToCommit, sender: self)
    }
    
    // MARK: - UITableViewDataSource/Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.issues.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(IssueCellReuseIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: IssueCellReuseIdentifier)
        }
        
        let issue = self.viewModel.issues[indexPath.row]
        cell!.textLabel?.text = issue.subject
        cell!.detailTextLabel?.text = issue.assignedTo?.name
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let issueModel = self.viewModel.issues[indexPath.row]
        let viewModel = OZLIssueViewModel(issueModel: issueModel)
        
        let issueVC = OZLIssueViewController()
        issueVC.viewModel = viewModel
        
        self.splitViewController?.showViewController(issueVC, sender: self)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let distanceFromBottom = scrollView.contentSize.height -
                                 scrollView.contentOffset.y -
                                 scrollView.frame.size.height;
        
        if self.viewModel.isLoading {
            return;
        }
        
        weak var weakSelf = self
        
        if self.viewModel.moreIssuesAvailable && distanceFromBottom <= 44.0 &&
            self.tableView.contentSize.height > self.tableView.frame.size.height {
                
                self.viewModel.loadMoreIssuesCompletion({ (error) -> Void in
                    if let weakSelf = weakSelf {
                        weakSelf.tableView.reloadData()
                        
                        if (!weakSelf.viewModel.moreIssuesAvailable) {
                            weakSelf.hideFooterActivityIndicator()
                        }
                    }
                })
        }
    }
    
    // MARK: - Behavior
    func refreshProjectSelector() {
        if self.viewModel.shouldShowProjectSelector {
            var titlesArray: Array<String> = []
            
            for i in 0..<self.viewModel.projects.count {
                let project = self.viewModel.projects[i]
                titlesArray.append(project.name)
            }
            
            // BTNavigationDropdownMenu must be initialized with its items, so we have to re-initialize it every 
            // time we want to change the items. Blech.
            if let nav = self.navigationController {
                let dropdown = BTNavigationDropdownMenu(navigationController: nav, title: self.viewModel.title, items: titlesArray)
                dropdown.cellTextLabelFont = UIFont.OZLMediumSystemFontOfSize(17.0)
                
                // use the parent view controller's tint color. BTNavigationDropdownMenu doesn't properly
                // respond to tintColorDidChange, so using this view's tint color won't do any good, as
                // we're not added to the window yet.
                dropdown.tintColor = self.parentViewController?.view.tintColor
                dropdown.cellBackgroundColor = UIColor(red:(249 / 255), green:(249 / 255), blue:(249 / 255), alpha:1)
                dropdown.cellSeparatorColor = UIColor.lightGrayColor()
                dropdown.cellTextLabelColor = UIColor.darkGrayColor()
                dropdown.cellSelectionColor = UIColor.OZLVeryLightGrayColor()
                dropdown.arrowImage = dropdown.arrowImage.imageWithRenderingMode(.AlwaysTemplate)
                dropdown.checkMarkImage = nil;
                
                weak var weakSelf = self
                
                dropdown.didSelectItemAtIndexHandler = { (index: Int) in
                    weakSelf?.didSelectProjectAtIndex(index)
                }
                
                self.navigationItem.titleView = dropdown;
            }
        }
    }

    func reloadProjectData() {
        weak var weakSelf = self
        
        self.viewModel.loadIssuesCompletion({ (error) -> Void in
            if let weakSelf = weakSelf {
                if let error = error {
                    let alert = UIAlertController(title: "Couldn't load issue list", message: error.localizedDescription, preferredStyle: .Alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    weakSelf.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    weakSelf.tableView.reloadData()
                    
                    if self.viewModel.moreIssuesAvailable {
                        weakSelf.hideFooterActivityIndicator()
                    }
                }
            }
        })
    }
    
    func showFooterActivityIndicator() {
        if self.tableView.tableFooterView != nil && self.tableView.tableFooterView?.tag != ZeroHeightFooterTag {
            return
        }
    
        let height = (OZLContentPadding * 2) + IssueListComposeButtonHeight
    
        let loadingView = OZLLoadingView(frame: CGRectMake(0, 0, self.view.frame.size.width, height))
        loadingView.loadingSpinner.startAnimating()
        self.tableView.tableFooterView = loadingView;
    }
    
    func hideFooterActivityIndicator() {
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 0, CGFloat.min))
        self.tableView.tableFooterView!.tag = ZeroHeightFooterTag
    }
}
