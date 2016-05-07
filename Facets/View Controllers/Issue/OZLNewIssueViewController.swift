//
//  OZLNewIssueViewController.swift
//  Facets
//
//  Created by Justin Hill on 5/2/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

class OZLNewIssueViewController: OZLTableViewController, OZLIssueViewModelDelegate, UIViewControllerTransitioningDelegate {

    private let ReuseIdentifier = "ReuseIdentifier"
    private let DescriptionReuseIdentifier = "DescriptionReuseIdentifier"
    private let RecentActivityReuseIdentifier = "RecentActivityReuseIdentifier"

    var contentPadding: CGFloat = OZLContentPadding
    var viewModel: OZLIssueViewModel
    var header = OZLIssueHeaderView()

    init(viewModel: OZLIssueViewModel) {
        self.viewModel = viewModel
        super.init(style: .Grouped)

        self.viewModel.delegate = self
        self.applyViewModel(self.viewModel)
        viewModel.loadIssueData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = .None

        self.header.contentPadding = OZLContentPadding;
        self.header.assignButton.addTarget(self, action: #selector(quickAssignAction), forControlEvents: .TouchUpInside)

        self.tableView.registerClass(OZLTableViewCell.self, forCellReuseIdentifier: ReuseIdentifier)
        self.tableView.registerClass(OZLIssueDescriptionCell.self, forCellReuseIdentifier: DescriptionReuseIdentifier)
        self.tableView.registerClass(OZLJournalCell.self, forCellReuseIdentifier: RecentActivityReuseIdentifier)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshHeaderSizeForWidth(self.view.frame.size.width)
    }

    func refreshHeaderSizeForWidth(width: CGFloat) {
        self.header.frame.size = self.header.sizeThatFits(CGSizeMake(width, UIViewNoIntrinsicMetric))
        self.tableView.tableHeaderView = self.header;
    }

    func applyViewModel(viewModel: OZLIssueViewModel) {
        if let trackerName = viewModel.issueModel.tracker?.name {
            self.title = "\(trackerName) #\(viewModel.issueModel.index)"
        }

        self.header.applyIssueModel(viewModel.issueModel)
        self.tableView.reloadData()
    }

    func quickAssignAction() {
        let vc = OZLQuickAssignViewController(issueModel: self.viewModel.issueModel)
        vc.modalPresentationStyle = .Custom
        vc.transitioningDelegate = self
        vc.delegate = self.viewModel

        self.presentViewController(vc, animated: true, completion: nil)
    }

    // MARK: - UITableViewDelegate/DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.viewModel.currentSectionNames.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = self.viewModel.currentSectionNames[section]

        if sectionName == OZLIssueViewModel.SectionDetail {
            return 5
        } else if sectionName == OZLIssueViewModel.SectionAttachments {
            return self.viewModel.issueModel.attachments?.count ?? 0
        } else if sectionName == OZLIssueViewModel.SectionDescription {
            return 1
        } else if sectionName == OZLIssueViewModel.SectionRecentActivity {
            return self.viewModel.recentActivityCount()
        }

        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: OZLTableViewCell?

        let sectionName = self.viewModel.currentSectionNames[indexPath.section]

        if sectionName == OZLIssueViewModel.SectionDetail {
            cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier, forIndexPath: indexPath) as? OZLTableViewCell
            cell?.textLabel?.text = "\(indexPath.row)"
        } else if sectionName == OZLIssueViewModel.SectionAttachments {
            cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier, forIndexPath: indexPath) as? OZLTableViewCell
            cell?.textLabel?.text = self.viewModel.issueModel.attachments?[indexPath.row].name
        } else if sectionName == OZLIssueViewModel.SectionDescription {
            cell = tableView.dequeueReusableCellWithIdentifier(DescriptionReuseIdentifier, forIndexPath: indexPath) as? OZLTableViewCell

            if let cell = cell as? OZLIssueDescriptionCell {
                cell.descriptionPreviewString = self.viewModel.issueModel.issueDescription
            }
        } else if sectionName == OZLIssueViewModel.SectionRecentActivity {
            cell = tableView.dequeueReusableCellWithIdentifier(RecentActivityReuseIdentifier, forIndexPath: indexPath) as? OZLTableViewCell

            if let cell = cell as? OZLJournalCell {
                cell.journal = self.viewModel.recentActivityAtIndex(indexPath.row)
            }
        }

        cell?.contentPadding = self.contentPadding

        return cell ?? UITableViewCell()
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let sectionName = self.viewModel.currentSectionNames[indexPath.section]

        if sectionName == OZLIssueViewModel.SectionDescription {
            return OZLIssueDescriptionCell.heightWithWidth(self.view.frame.size.width,
                                                           description: self.viewModel.issueModel.issueDescription,
                                                           contentPadding: self.contentPadding)
        } else if sectionName == OZLIssueViewModel.SectionRecentActivity {
            return OZLJournalCell.heightWithWidth(self.view.frame.size.width,
                                                  contentPadding: self.contentPadding,
                                                  journalModel: self.viewModel.recentActivityAtIndex(indexPath.row))
        }

        return 44.0
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let header = OZLIssueSectionHeaderView()
        header.contentPadding = self.contentPadding

        let sectionName = self.viewModel.currentSectionNames[section]
        header.titleLabel.text = self.viewModel.displayNameForSectionName(sectionName)

        if sectionName == OZLIssueViewModel.SectionRecentActivity {
            header.disclosureButton.setTitle("Show all \u{203a}", forState: .Normal)
            header.disclosureButton.addTarget(self, action: #selector(showAllActivityAction), forControlEvents: .TouchUpInside)
        } else if sectionName == OZLIssueViewModel.SectionDescription {
            header.disclosureButton.setTitle("Show full description \u{203a}", forState: .Normal)
            header.disclosureButton.addTarget(self, action: #selector(showFullDescriptionAction), forControlEvents: .TouchUpInside)
        }

        return header
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.min
        }

        return 40.0
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionName = self.viewModel.currentSectionNames[section]

        if sectionName == OZLIssueViewModel.SectionDetail {
            return 30.0
        }

        return CGFloat.min
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName = self.viewModel.currentSectionNames[section]

        return self.viewModel.displayNameForSectionName(sectionName)
    }

    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionName = self.viewModel.currentSectionNames[section]

        if sectionName == OZLIssueViewModel.SectionDetail {
            return "Show all • Edit pinned properties"
        }

        return nil
    }

    // MARK: - Button actions
    func showAllActivityAction() {
        let vm = OZLJournalViewerViewModel(issue: self.viewModel.issueModel)
        let vc = OZLJournalViewerViewController(viewModel: vm)

        self.navigationController?.pushViewController(vc, animated: true)
    }

    func showFullDescriptionAction() {
        let vc = OZLIssueFullDescriptionViewController()
        vc.descriptionLabel.text = self.viewModel.issueModel.issueDescription
        vc.contentPadding = self.contentPadding

        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - View model delegate
    func viewModel(viewModel: OZLIssueViewModel, didFinishLoadingIssueWithError error: NSError?) {
        self.applyViewModel(viewModel)
    }

    func viewModelIssueContentDidChange(viewModel: OZLIssueViewModel) {
        self.applyViewModel(viewModel)
    }

    // MARK: - Transitioning delegate
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return OZLSheetPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}
