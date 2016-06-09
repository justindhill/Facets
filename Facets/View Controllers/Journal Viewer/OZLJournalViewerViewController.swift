//
//  OZLJournalViewerViewController.swift
//  Facets
//
//  Created by Justin Hill on 2/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

@objc class OZLJournalViewerViewController: UITableViewController {
    
    let JournalCellReuseIdentifier = "JournalCellReuseIdentifier"
    let viewModel: OZLJournalViewerViewModel

    init(viewModel: OZLJournalViewerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Activity"

        self.tableView.estimatedRowHeight = 88
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .None
        self.tableView.registerClass(OZLJournalCell.self, forCellReuseIdentifier:self.JournalCellReuseIdentifier)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfJournals()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(self.JournalCellReuseIdentifier, forIndexPath: indexPath) as? OZLJournalCell else {
            assertionFailure("Failed to dequeue a Journal cell")
            return UITableViewCell()
        }
        
        guard let journal = self.viewModel.journalAtIndex(indexPath.row) else {
            assertionFailure("View model didn't return a journal")
            return cell
        }
        
        cell.journal = journal
        
        return cell
    }
}
