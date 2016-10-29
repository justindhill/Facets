//
//  OZLListSelectorViewController.swift
//  Facets
//
//  Created by Justin Hill on 5/27/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

protocol OZLListSelectorItem {
    var title: String { get }
    var comparator: String { get }
    var imageUrl: NSURL? { get }
}

protocol OZLListSelectorDelegate: AnyObject {
    func selector(selector: OZLListSelectorViewController, didSelectItem item: OZLListSelectorItem)
}

class OZLListSelectorViewController: OZLTableViewController, UIViewControllerTransitioningDelegate {

    private let layoutMargin: CGFloat = 20.0

    weak var delegate: OZLListSelectorDelegate?
    private(set) var items: [OZLListSelectorItem] = []
    private(set) var selectedItem: OZLListSelectorItem?
    private var transitionAnimator: OZLDropdownTransitionAnimator?
    private var selectedItemIndex: Int = NSNotFound

    private let ReuseIdentifier = "ReuseIdentifier"

    // MARK: Life cycle
    init(items: [OZLListSelectorItem], selectedItem: OZLListSelectorItem? = nil) {
        self.items = items
        self.selectedItem = selectedItem
        super.init(style: .Plain)

        self.selectedItemIndex = items.indexOf { (item) -> Bool in
            item.comparator == self.selectedItem?.comparator
        } ?? NSNotFound

        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier)
        self.tableView.rowHeight = 50.0
        self.tableView.alwaysBounceVertical = false
        self.tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        self.view.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundColor = UIColor.clearColor()

        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: self.layoutMargin, bottom: 0, right: self.layoutMargin)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.reloadData()

        let maxRows = Int(self.view.frame.size.height * (2/3)) / Int(self.tableView.rowHeight)
        let contentHeight = min(self.tableView.contentSize.height, CGFloat(maxRows) * self.tableView.rowHeight)
        self.preferredContentSize = CGSizeMake(self.view.frame.size.width, contentHeight)

        // viewWillLayoutSubviews will pick up the height change during the normal layout pass, but the height needs
        // to be adjusted immediately so the scroll offset is correct here.
        self.tableView.frame.size.height = contentHeight

        if self.selectedItemIndex != NSNotFound {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.selectedItemIndex, inSection: 0), atScrollPosition: .Middle, animated: false)
        }
    }

    // MARK: UITableViewDelegate/DataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = item.title
        cell.textLabel?.textColor = UIColor.darkGrayColor()
        cell.backgroundColor = UIColor.clearColor()
        cell.layoutMargins = UIEdgeInsets(top: 0, left: self.layoutMargin, bottom: 0, right: self.layoutMargin)
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.cornerRadius = 25

        let selectedBgView = UIView()
        selectedBgView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.05)
        cell.selectedBackgroundView = selectedBgView

        if let imageUrl = item.imageUrl {
            cell.imageView?.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(), options: [])
        } else {
            cell.imageView?.image = nil
        }

        if item.comparator == self.selectedItem?.comparator {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.selector(self, didSelectItem: self.items[indexPath.row])
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Transitioning
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController?, sourceViewController source: UIViewController) -> UIPresentationController? {
        if let nav = source.navigationController {
            return OZLDropdownPresentationController(presentedViewController: presented,
                                                     presentingViewController: presenting!,
                                                     navigationController: nav)
        }

        return nil
    }

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let nav = source.navigationController {
            self.transitionAnimator = OZLDropdownTransitionAnimator(navigationController:nav)
            return self.transitionAnimator
        }

        return nil
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionAnimator?.presenting = false

        return self.transitionAnimator
    }
}
