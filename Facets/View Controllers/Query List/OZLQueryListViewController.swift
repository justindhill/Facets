//
//  OZLQueryListViewController.swift
//  Facets
//
//  Created by Justin Hill on 3/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLQueryListViewController: OZLTableViewController {

    let OZLQueryReuseIdentifier = "OZLQueryReuseIdentifier"

    var isFirstAppearance = true
    var queries: [OZLModelQuery] = []
    var displayedProjectId = NSNotFound
    var loadingView = OZLLoadingView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        self.view.addSubview(self.loadingView)
        self.isFirstAppearance = true

        self.title = "Queries"

        self.tableViewController.refreshControl = UIRefreshControl()
        self.tableViewController.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: OZLQueryReuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let needsRefresh = self.displayedProjectId == NSNotFound || !(self.displayedProjectId == OZLSingleton.sharedInstance().currentProjectID)

        if needsRefresh {
            self.queries = []
            self.tableView.reloadData()
            self.refreshData()
        }

        self.isFirstAppearance = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.loadingView.frame = self.view.bounds
    }

    // MARK: - UITableViewDataSource/Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.queries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OZLQueryReuseIdentifier, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = self.queries[indexPath.row].name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let query = self.queries[indexPath.row]

        let vm = OZLIssueListViewModel()
        vm.title = query.name
        vm.projectId = query.projectId
        vm.queryId = query.queryId

        let vc = OZLIssueListViewController(style: .plain)
        vc.viewModel = vm
        vc.view.tag = OZLSplitViewController.PrimaryPaneMember

        self.navigationController?.pushViewController(vc, animated: true)
    }

    func refreshData() {
        if self.queries.count == 0 {
            self.loadingView.isHidden = false
            self.loadingView.startLoading()
        } else if !(self.tableViewController.refreshControl?.isRefreshing ?? false) {
            self.tableViewController.refreshControl?.beginRefreshing()
        }

        weak var weakSelf = self
        let projectId = OZLSingleton.sharedInstance().currentProjectID

        OZLNetwork.sharedInstance().getQueryList(forProject: projectId, params: nil) { (result, error) in
            guard let weakSelf = weakSelf else {
                return
            }
            
            if error != nil {
                weakSelf.loadingView.endLoadingWithErrorMessage("There was a problem loading the query list. Please check your connection and try again.")
            } else {
                let count = result?.count ?? 0
                weakSelf.loadingView.endLoadingWithErrorMessage(count > 0 ? nil : "Nothing to see here.")
                weakSelf.displayedProjectId = projectId
                weakSelf.queries = result as? [OZLModelQuery] ?? []
            }

            weakSelf.loadingView.isHidden = ((error == nil) && weakSelf.queries.count > 0)
            weakSelf.tableView.reloadData()
            weakSelf.tableViewController.refreshControl?.endRefreshing()
        }
    }
}
