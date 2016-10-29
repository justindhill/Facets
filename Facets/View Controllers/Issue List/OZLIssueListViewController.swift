//
//  OZLIssueListViewController.swift
//  Facets
//
//  Created by Justin Hill on 1/2/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit
import DRPLoadingSpinner

class OZLIssueListViewController: OZLTableViewController, OZLIssueListViewModelDelegate, UIViewControllerPreviewingDelegate, OZLSortAndFilterViewControllerDelegate, OZLNavigationChildChangeListener, OZLListSelectorDelegate {
    
    fileprivate let IssueListComposeButtonHeight: CGFloat = 56.0
    fileprivate let ZeroHeightFooterTag = -1
    
    fileprivate let IssueCellReuseIdentifier = "IssueCellReuseIdentifier"
    
    fileprivate var isFirstAppearance = true
    fileprivate var composeButton: UIButton?
    fileprivate let refreshControl = DRPRefreshControl.facetsBranded()
    
    var viewModel: OZLIssueListViewModel! {
        willSet(newValue) {
            newValue?.delegate = self
        }
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.tintAdjustmentMode = .normal

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        self.definesPresentationContext = true

        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: OZLContentPadding, bottom: 0, right: OZLContentPadding)
        self.tableView.estimatedRowHeight = 100

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(UINib(nibName: "OZLIssueTableViewCell", bundle: Bundle.main),
                                   forCellReuseIdentifier: IssueCellReuseIdentifier)

        self.refreshControl.add(to: self.tableViewController, target: self, selector: #selector(reloadProjectData))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel?.projectId = OZLSingleton.sharedInstance().currentProjectID

        if self.viewModel.shouldShowProjectSelector && self.isFirstAppearance {
            let titleButton = OZLDownChevronTitleView()
            titleButton.title = self.viewModel.title
            titleButton.addTarget(self, action: #selector(showProjectSelector), for: .touchUpInside)
            titleButton.shrinkwrapContent()
            self.navigationItem.titleView = titleButton
        } else if !self.viewModel.shouldShowProjectSelector {
            self.navigationItem.title = self.viewModel.title
        }
        
        if self.isFirstAppearance {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-filter"), style: .done, target: self, action: #selector(OZLIssueListViewController.filterAction(_:)))
            
            self.showFooterActivityIndicator()
            self.reloadProjectData()
        }

        if self.viewModel.shouldShowComposeButton && self.composeButton?.superview == nil {
            self.addComposeButton()
            
        } else if !self.viewModel.shouldShowComposeButton && self.composeButton?.superview != nil {
            self.composeButton?.removeFromSuperview()
            self.composeButton = nil
        }
        
        if let selectedIndexPaths = self.tableView.indexPathsForSelectedRows, self.presentedViewController == nil {
            for indexPath in selectedIndexPaths {
                self.tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 9.0, *) {
            if self.traitCollection.forceTouchCapability == .available {
                self.registerForPreviewing(with: self, sourceView: self.view)
            }
        }

        self.isFirstAppearance = false
    }

    // MARK: - Behavior
    func addComposeButton() {
        let composeButton = UIButton(type: .system)
        self.composeButton = composeButton

        composeButton.setImage(UIImage.ozl_imageNamed("icon-plus", maskedWith: UIColor.white), for:UIControlState())
        composeButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        composeButton.contentHorizontalAlignment = .center
        composeButton.contentVerticalAlignment = .center
        
        composeButton.layer.shadowColor = UIColor.black.cgColor
        composeButton.layer.shadowOpacity = 0.2
        composeButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        composeButton.frame = CGRect(x: 0, y: 0, width: self.IssueListComposeButtonHeight, height: self.IssueListComposeButtonHeight)
        composeButton.layer.cornerRadius = (IssueListComposeButtonHeight / 2.0)
        composeButton.addTarget(self, action: #selector(OZLIssueListViewController.composeButtonAction(_:)), for:.touchUpInside)

        composeButton.setBackgroundImage(
            UIColor.black.circularImageWithDiameter(self.IssueListComposeButtonHeight).withRenderingMode(.alwaysTemplate),
            for: UIControlState()
        )

        self.view.addSubview(composeButton)

        composeButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view).offset(-OZLContentPadding)
            make.trailing.equalTo(self.view.snp.trailing).offset(-OZLContentPadding)
            make.width.equalTo(IssueListComposeButtonHeight)
            make.height.equalTo(IssueListComposeButtonHeight)
        }
    }

    // MARK: - Button actions
    func filterAction(_ sender: UIButton?) {
        let sortAndFilter = OZLSortAndFilterViewController()
        sortAndFilter.delegate = self
        sortAndFilter.options = self.viewModel.sortAndFilterOptions
        
        let nav = UINavigationController(rootViewController: sortAndFilter)

        if let rightBarButtonItem = self.navigationItem.rightBarButtonItem {
            if UIDevice.current.userInterfaceIdiom == .pad {
                nav.modalPresentationStyle = .popover
                nav.popoverPresentationController?.barButtonItem = rightBarButtonItem
                
            } else {
                nav.modalPresentationStyle = .formSheet
            }
            
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func composeButtonAction(_ sender: UIButton?) {
        let composer = OZLIssueComposerViewController(currentProjectID: OZLSingleton.sharedInstance().currentProjectID)
        composer.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(OZLIssueListViewController.dismissComposerAction(_:)))
        
        let nav = UINavigationController(rootViewController: composer)
        nav.modalPresentationStyle = .formSheet
        
        self.present(nav, animated: true, completion: nil)
    }
    
    func dismissComposerAction(_ sender: UIButton?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - OZLSortAndFilterViewControllerDelegate
    func sortAndFilter(_ sortAndFilter: OZLSortAndFilterViewController, shouldDismissWithNewOptions newOptions: OZLSortAndFilterOptions?) {
        if let newOptions = newOptions, self.viewModel.sortAndFilterOptions != newOptions {
            self.viewModel!.sortAndFilterOptions = newOptions
            self.tableView.reloadData()
            self.showFooterActivityIndicator()
            self.reloadProjectData()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - OZLNavigationChildChangeListener
    func navigationChild(_ navigationChild: UIViewController!, didModifyIssue issue: OZLModelIssue!) {
        self.viewModel.processUpdatedIssue(issue)
    }
    
    // MARK: - OZLIssueListViewModelDelegate
    func viewModelIssueListContentDidChange(_ viewModel: OZLIssueListViewModel) {
        self.tableView.reloadData()
    }
    
    // MARK: - Previewing
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let translatedPoint = CGPoint(x: location.x, y: self.tableView.contentOffset.y + location.y)
        let indexPath = self.tableView.indexPathForRow(at: translatedPoint)
        
        if let indexPath = indexPath {
            let issue = self.viewModel.issues[indexPath.row]
            let viewModel = OZLIssueViewModel(issueModel: issue)
            
            let issueVC = OZLIssueViewController(viewModel: viewModel)
            issueVC.previewQuickAssignDelegate = self.viewModel

            return issueVC
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.show(viewControllerToCommit, sender: self)
    }
    
    // MARK: - UITableViewDataSource/Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.issues.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IssueCellReuseIdentifier, for: indexPath)

        if let cell = cell as? OZLIssueTableViewCell {
            let issue = self.viewModel.issues[indexPath.row]
            cell.applyIssueModel(issue)
            cell.contentPadding = OZLContentPadding

            if #available(iOS 9.0, *) {
                // intentionally empty body
            } else if cell.superview == nil {
                cell.frame.size.width = self.tableView.frame.size.width

                if self.traitCollection.userInterfaceIdiom == .pad {
                    cell.layoutMargins = UIEdgeInsetsMake(10, 20, 10, 20)
                } else {
                    cell.layoutMargins = UIEdgeInsetsMake(11, 16, 11, 16)
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let issueModel = self.viewModel.issues[indexPath.row]
        let viewModel = OZLIssueViewModel(issueModel: issueModel)

        let issueVC = OZLIssueViewController(viewModel: viewModel)

        self.splitViewController?.show(issueVC, sender: self)
    }
    
    // MARK - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let distanceFromBottom = scrollView.contentSize.height -
                                 scrollView.contentOffset.y -
                                 scrollView.frame.size.height;
        
        if self.viewModel.isLoading {
            return;
        }
        
        weak var weakSelf = self
        
        if self.viewModel.moreIssuesAvailable && distanceFromBottom <= 44.0 &&
            self.tableView.contentSize.height > self.tableView.frame.size.height {
                self.showFooterActivityIndicator()
                self.viewModel.loadMoreIssuesCompletion({ (error) -> Void in
                    if let weakSelf = weakSelf {
                        weakSelf.tableView.reloadData()
                        weakSelf.hideFooterActivityIndicator()
                    }
                })
        }
    }

    // MARK: - List selector delegate
    func selector(_ selector: OZLListSelectorViewController, didSelectItem item: OZLListSelectorItem) {
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

        self.present(vc, animated: true, completion: nil)
    }

    func reloadProjectData() {
        weak var weakSelf = self
        
        self.viewModel.loadIssuesCompletion({ (error) -> Void in

            if let refreshControl = weakSelf?.refreshControl {
                refreshControl.endRefreshing()
            }

            if let weakSelf = weakSelf {
                if let error = error {
                    let alert = UIAlertController(title: "Couldn't load issue list", message: error.localizedDescription, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    weakSelf.present(alert, animated: true, completion: nil)
                    
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
    
        let loadingView = OZLLoadingView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height))
        self.tableView.tableFooterView = loadingView;
        loadingView.startLoading()
    }
    
    func hideFooterActivityIndicator() {
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
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
