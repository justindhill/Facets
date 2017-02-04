//
//  OZLTableViewController.swift
//  Facets
//
//  Created by Justin Hill on 3/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableViewController: UITableViewController!
    lazy var loadingView = OZLLoadingView()


    init(style: UITableViewStyle) {
        self.tableViewController = UITableViewController(style: style)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.tableViewController = UITableViewController(style: .grouped)
        super.init(coder: aDecoder)
    }

    var tableView: UITableView {
        get {
            return self.tableViewController.tableView
        }
    }

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.addChildViewController(self.tableViewController)
        self.view.addSubview(self.tableViewController.tableView)
        self.tableViewController.didMove(toParentViewController: self)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.tableView.frame = self.view.bounds
        self.loadingView.frame = self.view.bounds
    }

    // MARK: - UITableViewDelegate/DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: .default, reuseIdentifier: "DefaultReuseId")
    }
    
    func startLoading() {
        self.view.addSubview(self.loadingView)
        self.loadingView.isHidden = false
        self.loadingView.startLoading()
    }
    
    func endLoading(errorMessage: String?) {
        self.loadingView.endLoadingWithErrorMessage(errorMessage)
        self.loadingView.isHidden = (errorMessage == nil)
    }
}
