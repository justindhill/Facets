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

    init(style: UITableViewStyle) {
        self.tableViewController = UITableViewController(style: style)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.tableViewController = UITableViewController(style: .Grouped)
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
        self.tableViewController.didMoveToParentViewController(self)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.tableView.frame = self.view.bounds
    }

    // MARK: - UITableViewDelegate/DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell(style: .Default, reuseIdentifier: "DefaultReuseId")
    }
}
