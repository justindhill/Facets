//
//  OZLIssueListViewController.swift
//  Facets
//
//  Created by Justin Hill on 1/2/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLIssueListViewController: OZLTableViewController, OZLIssueListViewModelDelegate, UIViewControllerPreviewingDelegate, OZLSortAndFilterViewControllerDelegate, OZLNavigationChildChangeListener, OZLListSelectorDelegate {
    
    private let IssueListComposeButtonHeight: CGFloat = 56.0
    private let ZeroHeightFooterTag = -1
    
    private let IssueCellReuseIdentifier = "IssueCellReuseIdentifier"
    
    private var isFirstAppearance = true
    private var composeButton: UIButton?
    
    var viewModel: OZLIssueListViewModel! {
        willSet(newValue) {
            newValue?.delegate = self
        }
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.tintAdjustmentMode = .Normal

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        self.definesPresentationContext = true

        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: OZLContentPadding, bottom: 0, right: OZLContentPadding)
        self.tableView.estimatedRowHeight = 100

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.registerNib(UINib(nibName: "OZLIssueTableViewCell", bundle: NSBundle.mainBundle()),
                                   forCellReuseIdentifier: IssueCellReuseIdentifier)

        self.tableViewController.refreshControl = UIRefreshControl()
        self.tableViewController.refreshControl?.addTarget(self, action: #selector(reloadProjectData), forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel?.projectId = OZLSingleton.sharedInstance().currentProjectID

        if self.viewModel.shouldShowProjectSelector && self.isFirstAppearance {
            let titleButton = OZLDownChevronTitleView()
            titleButton.title = self.viewModel.title
            titleButton.addTarget(self, action: #selector(showProjectSelector), forControlEvents: .TouchUpInside)
            titleButton.shrinkwrapContent()
            self.navigationItem.titleView = titleButton
        } else if !self.viewModel.shouldShowProjectSelector {
            self.navigationItem.title = self.viewModel.title
        }
        
        if self.isFirstAppearance {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-filter"), style: .Done, target: self, action: #selector(OZLIssueListViewController.filterAction(_:)))
            
            self.showFooterActivityIndicator()
            self.reloadProjectData()
        }

        if self.viewModel.shouldShowComposeButton && self.composeButton?.superview == nil {
            self.addComposeButton()
            
        } else if !self.viewModel.shouldShowComposeButton && self.composeButton?.superview != nil {
            self.composeButton?.removeFromSuperview()
            self.composeButton = nil
        }
        
        if let selectedIndexPaths = self.tableView.indexPathsForSelectedRows where self.presentedViewController == nil {
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

        self.isFirstAppearance = false
    }

    // MARK: - Behavior
    func addComposeButton() {
        let composeButton = UIButton(type: .System)
        self.composeButton = composeButton

        composeButton.setImage(UIImage.ozl_imageNamed("icon-plus", maskedWithColor: UIColor.whiteColor()), forState:.Normal)
        composeButton.titleLabel?.font = UIFont.systemFontOfSize(28)
        composeButton.contentHorizontalAlignment = .Center
        composeButton.contentVerticalAlignment = .Center
        
        composeButton.layer.shadowColor = UIColor.blackColor().CGColor
        composeButton.layer.shadowOpacity = 0.2
        composeButton.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
        composeButton.frame = CGRectMake(0, 0, self.IssueListComposeButtonHeight, self.IssueListComposeButtonHeight)
        composeButton.layer.cornerRadius = (IssueListComposeButtonHeight / 2.0)
        composeButton.addTarget(self, action: #selector(OZLIssueListViewController.composeButtonAction(_:)), forControlEvents:.TouchUpInside)

        composeButton.setBackgroundImage(
            UIColor.blackColor().circularImageWithDiameter(self.IssueListComposeButtonHeight).imageWithRenderingMode(.AlwaysTemplate),
            forState: .Normal
        )

        self.view.addSubview(composeButton)

        composeButton.snp_makeConstraints { (make) in
            make.bottom.equalTo(self.view).offset(-OZLContentPadding)
            make.trailing.equalTo(self.view.snp_trailing).offset(-OZLContentPadding)
            make.width.equalTo(IssueListComposeButtonHeight)
            make.height.equalTo(IssueListComposeButtonHeight)
        }
    }

    // MARK: - Button actions
    func filterAction(sender: UIButton?) {
        let sortAndFilter = OZLSortAndFilterViewController()
        sortAndFilter.delegate = self
        sortAndFilter.options = self.viewModel.sortAndFilterOptions
        
        let nav = UINavigationController(rootViewController: sortAndFilter)

        if let rightBarButtonItem = self.navigationItem.rightBarButtonItem {
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                let popover = UIPopoverController(contentViewController: nav)
                popover.presentPopoverFromBarButtonItem(rightBarButtonItem, permittedArrowDirections: .Any, animated: true)
            } else {
                nav.modalPresentationStyle = .FormSheet
                self.presentViewController(nav, animated: true, completion: nil)
            }
        }
    }
    
    func composeButtonAction(sender: UIButton?) {
        let composer = OZLIssueComposerViewController(currentProjectID: OZLSingleton.sharedInstance().currentProjectID)
        composer.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(OZLIssueListViewController.dismissComposerAction(_:)))
        
        let nav = UINavigationController(rootViewController: composer)
        nav.modalPresentationStyle = .FormSheet
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func dismissComposerAction(sender: UIButton?) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
            
            let issueVC = OZLIssueViewController(viewModel: viewModel)
            issueVC.previewQuickAssignDelegate = self.viewModel

            return issueVC
        }
        
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        self.showViewController(viewControllerToCommit, sender: self)
    }
    
    // MARK: - UITableViewDataSource/Delegate
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.issues.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(IssueCellReuseIdentifier)

        if let cell = cell as? OZLIssueTableViewCell {
            let issue = self.viewModel.issues[indexPath.row]
            cell.applyIssueModel(issue)
            cell.contentPadding = OZLContentPadding
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let issueModel = self.viewModel.issues[indexPath.row]
        let viewModel = OZLIssueViewModel(issueModel: issueModel)

        let issueVC = OZLIssueViewController(viewModel: viewModel)

        self.splitViewController?.showViewController(issueVC, sender: self)
    }
    
    // MARK - UIScrollViewDelegate
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

    // MARK: - List selector delegate
    func selector(selector: OZLListSelectorViewController, didSelectItem item: OZLListSelectorItem) {
        if let project = item as? OZLModelProject {
            self.showFooterActivityIndicator()
            OZLSingleton.sharedInstance().currentProjectID = project.projectId
            viewModel.projectId = project.projectId

            if let titleButton = self.navigationItem.titleView as? OZLDownChevronTitleView {
                titleButton.title = project.name
                self.navigationItem.titleView = nil
                titleButton.shrinkwrapContent()
                self.navigationItem.titleView = titleButton
            }

            self.tableView.reloadData()
            self.reloadProjectData()
        }
    }

    // MARK: - Behavior
    func showProjectSelector() {
        var projects: Array<OZLModelProject> = []
        var currentProject: OZLModelProject?

        for i in 0..<self.viewModel.projects.count {
            if let project = self.viewModel.projects[i] as? OZLModelProject {
                projects.append(project)

                if project.projectId == self.viewModel.projectId {
                    currentProject = project
                }
            }
        }

        let vc = OZLListSelectorViewController(items: projects.map({$0 as OZLListSelectorItem}), selectedItem: currentProject)
        vc.delegate = self

        self.presentViewController(vc, animated: true, completion: nil)
    }

    func reloadProjectData() {
        weak var weakSelf = self
        
        self.viewModel.loadIssuesCompletion({ (error) -> Void in

            if let refreshControl = weakSelf?.tableViewController.refreshControl where refreshControl.refreshing {
                refreshControl.endRefreshing()
            }

            if let weakSelf = weakSelf {
                if let error = error {
                    let alert = UIAlertController(title: "Couldn't load issue list", message: error.localizedDescription, preferredStyle: .Alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    weakSelf.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    weakSelf.tableView.reloadData()
                    
                    if !self.viewModel.moreIssuesAvailable {
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
        self.tableView.tableFooterView = loadingView;
        loadingView.startLoading()
    }
    
    func hideFooterActivityIndicator() {
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 0, CGFloat.min))
        self.tableView.tableFooterView!.tag = ZeroHeightFooterTag
    }
}

// MARK: - Project selector model extension
extension OZLModelProject: OZLListSelectorItem {
    var title: String {
        return self.name
    }

    var comparator: String {
        return String(self.projectId)
    }
}
