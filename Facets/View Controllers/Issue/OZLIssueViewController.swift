//
//  OZLIssueViewController.swift
//  Facets
//
//  Created by Justin Hill on 5/2/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

class OZLIssueViewController: OZLTableViewController, OZLIssueViewModelDelegate, UIViewControllerTransitioningDelegate {

    private let DetailReuseIdentifier = "DetailReuseIdentifier"
    private let AttachmentReuseIdentifier = "AttachmentReuseIdentifier"
    private let DescriptionReuseIdentifier = "DescriptionReuseIdentifier"
    private let RecentActivityReuseIdentifier = "RecentActivityReuseIdentifier"

    let ShowAllDetailsString = "Show all"
    let HideUnpinnedDetailsString = "Hide unpinned details"

    var contentPadding: CGFloat = OZLContentPadding
    var viewModel: OZLIssueViewModel
    var header = OZLIssueHeaderView()
    var attachmentManager = OZLSingleton.sharedInstance().attachmentManager

    weak var previewQuickAssignDelegate: OZLQuickAssignDelegate?

    //MARK: - Life cycle
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

        self.header.contentPadding = OZLContentPadding;
        self.header.assignButton.addTarget(self, action: #selector(quickAssignAction), forControlEvents: .TouchUpInside)

        self.tableView.registerClass(OZLIssueDetailCell.self, forCellReuseIdentifier: DetailReuseIdentifier)
        self.tableView.registerClass(OZLIssueAttachmentCell.self, forCellReuseIdentifier: AttachmentReuseIdentifier)
        self.tableView.registerClass(OZLIssueDescriptionCell.self, forCellReuseIdentifier: DescriptionReuseIdentifier)
        self.tableView.registerClass(OZLJournalCell.self, forCellReuseIdentifier: RecentActivityReuseIdentifier)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(editButtonAction(_:)))
        self.tableView.separatorStyle = .None
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

    func quickAssignAction(sender: UIControl) {
        let vc = OZLQuickAssignViewController(issueModel: self.viewModel.issueModel)

        if self.traitCollection.userInterfaceIdiom == .Pad {
            vc.modalPresentationStyle = .Popover
            vc.popoverPresentationController?.sourceView = sender.superview
            vc.popoverPresentationController?.sourceRect = sender.frame
            vc.preferredContentSize = CGSizeMake(320, 370)
        } else {
            vc.modalPresentationStyle = .Custom
            vc.transitioningDelegate = self
        }

        vc.delegate = self.viewModel

        self.presentViewController(vc, animated: true, completion: nil)
    }

    // MARK: - Previewing
    @available(iOS 9.0, *)
    override func previewActionItems() -> [UIPreviewActionItem] {
        var items = [UIPreviewActionItem]()

        items.append(UIPreviewAction(title: "Quick Assign", style: .Default, handler: { (action, previewViewController) in
            if let issueCopy = self.viewModel.issueModel.copy() as? OZLModelIssue {
                let vc = OZLQuickAssignViewController(issueModel: issueCopy)
                vc.transitioningDelegate = self
                vc.modalPresentationStyle = .Custom
                vc.delegate = self.previewQuickAssignDelegate

                UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
            }
        }))

        items.append(UIPreviewAction(title: "Edit", style: .Default, handler: { (action, previewViewController) in
            let vc = OZLIssueComposerViewController(issue: self.viewModel.issueModel)
            let nav = UINavigationController(rootViewController: vc)

            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(nav, animated: true, completion: nil)
        }))

        return items
    }

    // MARK: - UITableViewDelegate/DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.viewModel.currentSectionNames.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = self.viewModel.currentSectionNames[section]

        if sectionName == OZLIssueViewModel.SectionDetail {
            return self.viewModel.numberOfDetails()
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
        var cell: UITableViewCell?

        let sectionName = self.viewModel.currentSectionNames[indexPath.section]

        if sectionName == OZLIssueViewModel.SectionDetail {
            cell = tableView.dequeueReusableCellWithIdentifier(DetailReuseIdentifier, forIndexPath: indexPath)

            if let cell = cell as? OZLIssueDetailCell {
                let (name, value, isPinned) = self.viewModel.detailAtIndex(indexPath.row)
                cell.detailNameLabel.text = "\(name) - \(value)"
                cell.accessoryImageView.image = (isPinned && self.viewModel.showAllDetails) ? UIImage(named: "icon-checkmark") : nil

                cell.pinned = isPinned
                cell.unpinnedBackgroundColor = UIColor.OZLVeryLightGrayColor()
                cell.pinnedBackgroundColor = UIColor.whiteColor()

                if indexPath.row == 0 {
                    cell.cellPosition = .Top
                } else if indexPath.row == self.viewModel.numberOfDetails() - 1 {
                    cell.cellPosition = .Bottom
                } else {
                    cell.cellPosition = .Middle
                }
            }

        } else if sectionName == OZLIssueViewModel.SectionAttachments {
            cell = tableView.dequeueReusableCellWithIdentifier(AttachmentReuseIdentifier, forIndexPath: indexPath)

            if let cell = cell as? OZLIssueAttachmentCell, attachment = self.viewModel.issueModel.attachments?[indexPath.row] {
                cell.applyAttachmentModel(attachment)

                if OZLSingleton.sharedInstance().attachmentManager.isAttachmentCached(attachment) {
                    cell.accessoryView = nil
                    cell.accessoryType = .DisclosureIndicator
                } else {
                    cell.accessoryView = cell.downloadButton
                }

                cell.downloadButton.addTarget(self, action: #selector(downloadAttachmentAction(_:)), forControlEvents: .TouchUpInside)
            }
        } else if sectionName == OZLIssueViewModel.SectionDescription {
            cell = tableView.dequeueReusableCellWithIdentifier(DescriptionReuseIdentifier, forIndexPath: indexPath)

            if let cell = cell as? OZLIssueDescriptionCell {
                cell.descriptionPreviewString = self.viewModel.issueModel.issueDescription
            }
        } else if sectionName == OZLIssueViewModel.SectionRecentActivity {
            cell = tableView.dequeueReusableCellWithIdentifier(RecentActivityReuseIdentifier, forIndexPath: indexPath)

            if let cell = cell as? OZLJournalCell {
                cell.journal = self.viewModel.recentActivityAtIndex(indexPath.row)
            }
        }

        if let cell = cell {
            if #available(iOS 9.0, *) {
                // intentionally empty body
            } else if cell.superview == nil {
                cell.frame.size.width = self.tableView.frame.size.width

                if self.traitCollection.userInterfaceIdiom == .Pad {
                    cell.layoutMargins = UIEdgeInsetsMake(10, 20, 10, 20)
                } else {
                    cell.layoutMargins = UIEdgeInsetsMake(11, 16, 11, 16)
                }
            }
        }

        return cell ?? UITableViewCell()
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionName = self.viewModel.currentSectionNames[section]

        if sectionName == OZLIssueViewModel.SectionDetail {
            let footerView = OZLIssueDetailsSectionFooter()
            footerView.leftButton.setTitle(self.viewModel.showAllDetails ? HideUnpinnedDetailsString : ShowAllDetailsString, forState: .Normal)
            footerView.leftButton.addTarget(self, action: #selector(togglePinnedDetailsAction(_:)), forControlEvents: .TouchUpInside)

            return footerView
        }

        return nil
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.min
        }

        return 30.0
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

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let sectionName = self.viewModel.currentSectionNames[indexPath.section]

        if sectionName == OZLIssueViewModel.SectionDetail && self.viewModel.showAllDetails {
            return true
        }

        if sectionName == OZLIssueViewModel.SectionAttachments {
            if let attachment = self.viewModel.issueModel.attachments?[indexPath.row] {
                return OZLSingleton.sharedInstance().attachmentManager.isAttachmentCached(attachment)
            }
        }

        return false
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sectionName = self.viewModel.currentSectionNames[indexPath.section]

        if sectionName == OZLIssueViewModel.SectionDetail && self.viewModel.showAllDetails {
            self.viewModel.togglePinningForDetailAtIndex(indexPath.row)
            tableView.reloadRowsAtIndexPaths([ indexPath ], withRowAnimation: .None)
        }

        if sectionName == OZLIssueViewModel.SectionAttachments {
            if let attachment = self.viewModel.issueModel.attachments?[indexPath.row] {
                self.cachedAttachmentTapAction(attachment)
            }
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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

    func togglePinnedDetailsAction(button: UIButton) {
        button.setTitle(!self.viewModel.showAllDetails ? HideUnpinnedDetailsString : ShowAllDetailsString, forState: .Normal)
        button.superview?.setNeedsLayout()
        button.superview?.layoutIfNeeded()

        self.viewModel.showAllDetails = !self.viewModel.showAllDetails
    }

    func editButtonAction(button: UIButton) {
        let composer = OZLIssueComposerViewController(issue: self.viewModel.issueModel)

        let nav = UINavigationController(rootViewController: composer)
        nav.navigationBar.translucent = false
        nav.navigationBar.barTintColor = UIColor.whiteColor()
        nav.modalPresentationStyle = .FormSheet

        self.presentViewController(nav, animated: true, completion: nil)
    }

    func downloadAttachmentAction(button: UIButton) {
        let convertedFrame = self.tableView.convertRect(button.frame, fromView: button.superview)

        if let indexPath = self.tableView.indexPathForRowAtPoint(convertedFrame.origin) {
            if let attachment = self.viewModel.issueModel.attachments?[indexPath.row] {
                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? OZLIssueAttachmentCell
                cell?.accessoryView = cell?.progressView

                self.attachmentManager.downloadAttachment(attachment,
                    progress: { (attachment, totalBytesDownloaded, totalBytesExpected) in
                        let ratio = Double(totalBytesDownloaded) / Double(attachment.size)
                        cell?.progressView.progress = ratio
                        print("Progress for \(attachment): \(ratio))")
                    }, completion: { (data, error) in
                        cell?.accessoryType = .DisclosureIndicator
                        cell?.accessoryView = nil
                        print("Finished downloading \(attachment)")
                })

                print(attachment)
            }
        }
    }

    func cachedAttachmentTapAction(attachment: OZLModelAttachment) {
        if attachment.fileClassification == .Video {
            if let url = self.attachmentManager.fetchURLForLocalAttachment(attachment) {
                var cachesDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .AllDomainsMask, true).first!
                cachesDir = cachesDir.stringByAppendingString("/tmp.mp4")

                let tmpUrl = NSURL.fileURLWithPath(cachesDir)

                do {
                    do {
                        if try NSFileManager.defaultManager().attributesOfItemAtPath(cachesDir)[NSFileType] as? String == NSFileTypeSymbolicLink {
                            try NSFileManager.defaultManager().removeItemAtURL(tmpUrl)
                        }
                    } catch let error as NSError {
                        if error.domain != NSCocoaErrorDomain || error.code != 260 {
                            return
                        }
                    }

                    try NSFileManager.defaultManager().createSymbolicLinkAtURL(tmpUrl, withDestinationURL: url)
                } catch {
                    return
                }

                let player = AVPlayer(URL: tmpUrl)

                let vc = AVPlayerViewController()
                vc.player = player

                self.presentViewController(vc, animated: true, completion: { 
                    vc.player?.play()
                })
            }
        }
    }

    // MARK: - View model delegate
    func viewModel(viewModel: OZLIssueViewModel, didFinishLoadingIssueWithError error: NSError?) {
        self.applyViewModel(viewModel)
    }

    func viewModelIssueContentDidChange(viewModel: OZLIssueViewModel) {
        self.applyViewModel(viewModel)
    }

    func viewModelDetailDisplayModeDidChange(viewModel: OZLIssueViewModel) {
        self.tableView.beginUpdates()

        if let detailsSectionIndex = self.viewModel.sectionNumberForSectionName(OZLIssueViewModel.SectionDetail) {
            self.tableView.reloadSections(NSIndexSet(index: detailsSectionIndex), withRowAnimation: .Fade)
        }

        self.tableView.endUpdates()
    }

    // MARK: - Transitioning delegate
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return OZLSheetPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}
