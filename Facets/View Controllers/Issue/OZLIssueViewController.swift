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
import DRPLoadingSpinner

class OZLIssueViewController: OZLTableViewController, OZLIssueViewModelDelegate, UIViewControllerTransitioningDelegate {

    fileprivate let DetailReuseIdentifier = "DetailReuseIdentifier"
    fileprivate let AttachmentReuseIdentifier = "AttachmentReuseIdentifier"
    fileprivate let DescriptionReuseIdentifier = "DescriptionReuseIdentifier"
    fileprivate let RecentActivityReuseIdentifier = "RecentActivityReuseIdentifier"

    private let refreshControl = DRPRefreshControl.facetsBranded()
    
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
        super.init(style: .grouped)

        self.viewModel.delegate = self
        self.applyViewModel(self.viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.white

        self.header.contentPadding = OZLContentPadding;
        self.header.assignButton.addTarget(self, action: #selector(quickAssignAction), for: .touchUpInside)

        self.tableView.register(OZLIssueDetailCell.self, forCellReuseIdentifier: DetailReuseIdentifier)
        self.tableView.register(OZLIssueAttachmentCell.self, forCellReuseIdentifier: AttachmentReuseIdentifier)
        self.tableView.register(OZLIssueDescriptionCell.self, forCellReuseIdentifier: DescriptionReuseIdentifier)
        self.tableView.register(OZLJournalCell.self, forCellReuseIdentifier: RecentActivityReuseIdentifier)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonAction(_:)))
        self.tableView.separatorStyle = .none

        self.refreshControl.add(to: self.tableViewController, target: self, selector: #selector(pullToRefreshTriggered(_:)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshHeaderSizeForWidth(self.view.frame.size.width)
        
        if self.viewModel.completeness() != .all {
            let loadingView = OZLLoadingView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64))
            self.tableView.tableFooterView = loadingView
            loadingView.startLoading()
            
            self.viewModel.loadIssueData()
        }
    }

    func refreshHeaderSizeForWidth(_ width: CGFloat) {
        self.header.frame.size = self.header.sizeThatFits(CGSize(width: width, height: UIViewNoIntrinsicMetric))
        self.tableView.tableHeaderView = self.header;
    }

    func applyViewModel(_ viewModel: OZLIssueViewModel) {
        if let trackerName = viewModel.issueModel.tracker?.name {
            self.title = "\(trackerName) #\(viewModel.issueModel.index)"
        }

        self.header.applyIssueModel(viewModel.issueModel)
        self.tableView.reloadData()
    }

    func quickAssignAction(_ sender: UIControl) {
        let vc = OZLQuickAssignViewController(issueModel: self.viewModel.issueModel)

        if self.traitCollection.userInterfaceIdiom == .pad {
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.sourceView = sender.superview
            vc.popoverPresentationController?.sourceRect = sender.frame
            vc.preferredContentSize = CGSize(width: 320, height: 370)
        } else {
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
        }

        vc.delegate = self.viewModel

        self.present(vc, animated: true, completion: nil)
    }

    // MARK: - Previewing
    @available(iOS 9.0, *)
    override var previewActionItems : [UIPreviewActionItem] {
        var items = [UIPreviewActionItem]()

        items.append(UIPreviewAction(title: "Share", style: .default, handler: { (action, previewViewController) in
            let components = NSURLComponents(url: OZLNetwork.sharedInstance().baseURL, resolvingAgainstBaseURL: true)
            components?.path = "/issues/\(self.viewModel.issueModel.index)"

            if let url = components?.url {
                let activityViewController = UIActivityViewController(activityItems:[url] , applicationActivities: nil)
                UIApplication.shared.keyWindow?.rootViewController?.present(activityViewController, animated: true, completion: nil)
            }
        }))

        items.append(UIPreviewAction(title: "Quick Assign", style: .default, handler: { (action, previewViewController) in
            if let issueCopy = self.viewModel.issueModel.copy() as? OZLModelIssue {
                let vc = OZLQuickAssignViewController(issueModel: issueCopy)
                vc.transitioningDelegate = self
                vc.modalPresentationStyle = .custom
                vc.delegate = self.previewQuickAssignDelegate

                UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
            }
        }))

        items.append(UIPreviewAction(title: "Edit", style: .default, handler: { (action, previewViewController) in
            let vc = OZLIssueComposerViewController(issue: self.viewModel.issueModel)
            let nav = UINavigationController(rootViewController: vc)

            UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: true, completion: nil)
        }))

        return items
    }

    // MARK: - UITableViewDelegate/DataSource
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return self.viewModel.currentSectionNames.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?

        let sectionName = self.viewModel.currentSectionNames[indexPath.section]

        if sectionName == OZLIssueViewModel.SectionDetail {
            cell = tableView.dequeueReusableCell(withIdentifier: DetailReuseIdentifier, for: indexPath)

            if let cell = cell as? OZLIssueDetailCell {
                let (name, value, isPinned) = self.viewModel.detailAtIndex(indexPath.row)
                cell.detailNameLabel.text = "\(name) - \(value)"
                cell.accessoryImageView.image = (isPinned && self.viewModel.showAllDetails) ? UIImage(named: "icon-checkmark") : nil

                cell.pinned = isPinned
                cell.unpinnedBackgroundColor = UIColor.ozlVeryLightGray()
                cell.pinnedBackgroundColor = UIColor.white

                if indexPath.row == 0 {
                    cell.cellPosition = .top
                } else if indexPath.row == self.viewModel.numberOfDetails() - 1 {
                    cell.cellPosition = .bottom
                } else {
                    cell.cellPosition = .middle
                }
            }

        } else if sectionName == OZLIssueViewModel.SectionAttachments {
            cell = tableView.dequeueReusableCell(withIdentifier: AttachmentReuseIdentifier, for: indexPath)

            if let cell = cell as? OZLIssueAttachmentCell, let attachment = self.viewModel.issueModel.attachments?[indexPath.row] {
                cell.applyAttachmentModel(attachment)

                if OZLSingleton.sharedInstance().attachmentManager.isAttachmentCached(attachment) {
                    cell.accessoryView = nil
                    cell.accessoryType = .disclosureIndicator
                } else {
                    cell.accessoryView = cell.downloadButton
                }

                cell.downloadButton.addTarget(self, action: #selector(downloadAttachmentAction(_:)), for: .touchUpInside)
            }
        } else if sectionName == OZLIssueViewModel.SectionDescription {
            cell = tableView.dequeueReusableCell(withIdentifier: DescriptionReuseIdentifier, for: indexPath)

            if let cell = cell as? OZLIssueDescriptionCell {
                cell.descriptionPreviewString = self.viewModel.issueModel.issueDescription
            }
        } else if sectionName == OZLIssueViewModel.SectionRecentActivity {
            cell = tableView.dequeueReusableCell(withIdentifier: RecentActivityReuseIdentifier, for: indexPath)

            if let cell = cell as? OZLJournalCell {
                cell.journal = self.viewModel.recentActivityAtIndex(indexPath.row)
            }
        }

        if let cell = cell {
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

        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let header = OZLIssueSectionHeaderView()
        header.contentPadding = self.contentPadding

        let sectionName = self.viewModel.currentSectionNames[section]
        header.titleLabel.text = self.viewModel.displayNameForSectionName(sectionName)

        if sectionName == OZLIssueViewModel.SectionRecentActivity {
            header.disclosureButton.setTitle("Show all \u{203a}", for: UIControlState())
            header.disclosureButton.addTarget(self, action: #selector(showAllActivityAction), for: .touchUpInside)
        } else if sectionName == OZLIssueViewModel.SectionDescription {
            header.disclosureButton.setTitle("Show full description \u{203a}", for: UIControlState())
            header.disclosureButton.addTarget(self, action: #selector(showFullDescriptionAction), for: .touchUpInside)
        }

        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionName = self.viewModel.currentSectionNames[section]

        if sectionName == OZLIssueViewModel.SectionDetail {
            let footerView = OZLIssueDetailsSectionFooter()
            footerView.leftButton.setTitle(self.viewModel.showAllDetails ? HideUnpinnedDetailsString : ShowAllDetailsString, for: UIControlState())
            footerView.leftButton.addTarget(self, action: #selector(togglePinnedDetailsAction(_:)), for: .touchUpInside)

            return footerView
        }

        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }

        return 30.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionName = self.viewModel.currentSectionNames[section]

        if sectionName == OZLIssueViewModel.SectionDetail {
            return 30.0
        }

        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName = self.viewModel.currentSectionNames[section]

        return self.viewModel.displayNameForSectionName(sectionName)
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: IndexPath) -> Bool {
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

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let sectionName = self.viewModel.currentSectionNames[indexPath.section]

        if sectionName == OZLIssueViewModel.SectionDetail && self.viewModel.showAllDetails {
            self.viewModel.togglePinningForDetailAtIndex(indexPath.row)
            tableView.reloadRows(at: [ indexPath ], with: .none)
        }

        if sectionName == OZLIssueViewModel.SectionAttachments {
            if let attachment = self.viewModel.issueModel.attachments?[indexPath.row] {
                self.cachedAttachmentTapAction(attachment)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
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

    func togglePinnedDetailsAction(_ button: UIButton) {
        button.setTitle(!self.viewModel.showAllDetails ? HideUnpinnedDetailsString : ShowAllDetailsString, for: UIControlState())
        button.superview?.setNeedsLayout()
        button.superview?.layoutIfNeeded()

        self.viewModel.showAllDetails = !self.viewModel.showAllDetails
    }

    func editButtonAction(_ button: UIButton) {
        let composer = OZLIssueComposerViewController(issue: self.viewModel.issueModel)

        let nav = UINavigationController(rootViewController: composer)
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.barTintColor = UIColor.white

        self.present(nav, animated: true, completion: nil)
    }

    func downloadAttachmentAction(_ button: UIButton) {
        let convertedFrame = self.tableView.convert(button.frame, from: button.superview)

        if let indexPath = self.tableView.indexPathForRow(at: convertedFrame.origin) {
            if let attachment = self.viewModel.issueModel.attachments?[indexPath.row] {
                let cell = self.tableView.cellForRow(at: indexPath) as? OZLIssueAttachmentCell
                cell?.accessoryView = cell?.progressView

                self.attachmentManager?.downloadAttachment(attachment,
                    progress: { (attachment, totalBytesDownloaded, totalBytesExpected) in
                        let ratio = Double(totalBytesDownloaded) / Double(attachment.size)
                        cell?.progressView.progress = ratio
                        print("Progress for \(attachment): \(ratio))")
                    }, completion: { (data, error) in
                        cell?.accessoryType = .disclosureIndicator
                        cell?.accessoryView = nil
                        print("Finished downloading \(attachment)")
                })

                print(attachment)
            }
        }
    }

    func cachedAttachmentTapAction(_ attachment: OZLModelAttachment) {
        if attachment.fileClassification == .video {
            if let url = self.attachmentManager?.fetchURLForLocalAttachment(attachment) {
                var cachesDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .allDomainsMask, true).first!
                cachesDir = cachesDir + "/tmp.mp4"

                let tmpUrl = URL(fileURLWithPath: cachesDir)

                do {
                    do {
                        if try FileManager.default.attributesOfItem(atPath: cachesDir)[FileAttributeKey.type] as? FileAttributeType == FileAttributeType.typeSymbolicLink {
                            try FileManager.default.removeItem(at: tmpUrl)
                        }
                    } catch let error as NSError {
                        if error.domain != NSCocoaErrorDomain || error.code != 260 {
                            return
                        }
                    }

                    try FileManager.default.createSymbolicLink(at: tmpUrl, withDestinationURL: url)
                } catch {
                    return
                }

                let player = AVPlayer(url: tmpUrl)

                let vc = AVPlayerViewController()
                vc.player = player

                self.present(vc, animated: true, completion: { 
                    vc.player?.play()
                })
            }
        }
    }

    func pullToRefreshTriggered(_ sender: DRPRefreshControl) {
        self.viewModel.loadIssueData()
    }

    // MARK: - View model delegate
    func viewModel(_ viewModel: OZLIssueViewModel, didFinishLoadingIssueWithError error: NSError?) {
        self.tableView.tableFooterView = nil
        self.refreshControl.endRefreshing()
        self.applyViewModel(viewModel)
    }

    func viewModelIssueContentDidChange(_ viewModel: OZLIssueViewModel) {
        self.applyViewModel(viewModel)
    }

    func viewModelDetailDisplayModeDidChange(_ viewModel: OZLIssueViewModel) {
        self.tableView.beginUpdates()

        if let detailsSectionIndex = self.viewModel.sectionNumberForSectionName(OZLIssueViewModel.SectionDetail) {
            self.tableView.reloadSections(IndexSet(integer: detailsSectionIndex), with: .fade)
        }

        self.tableView.endUpdates()
    }

    // MARK: - Transitioning delegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return OZLSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
