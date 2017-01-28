//
//  OZLJournalViewerViewController.swift
//  Facets
//
//  Created by Justin Hill on 2/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

class OZLJournalViewerViewController: UITableViewController {
    
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
        self.tableView.separatorStyle = .none
        self.tableView.register(OZLJournalCell.self, forCellReuseIdentifier:self.JournalCellReuseIdentifier)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfJournals()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.JournalCellReuseIdentifier, for: indexPath) as? OZLJournalCell else {
            assertionFailure("Failed to dequeue a Journal cell")
            return UITableViewCell()
        }
        
        guard let journal = self.viewModel.journalAtIndex(indexPath.row) else {
            assertionFailure("View model didn't return a journal")
            return cell
        }
        
        cell.journal = journal

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

        return cell
    }
}
