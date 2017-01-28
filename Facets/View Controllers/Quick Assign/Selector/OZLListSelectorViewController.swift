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
}

protocol OZLListSelectorDelegate: AnyObject {
    func selector(_ selector: OZLListSelectorViewController, didSelectItem item: OZLListSelectorItem)
}

class OZLListSelectorViewController: OZLTableViewController, UIViewControllerTransitioningDelegate {

    fileprivate let layoutMargin: CGFloat = 20.0

    weak var delegate: OZLListSelectorDelegate?
    fileprivate(set) var items: [OZLListSelectorItem] = []
    fileprivate(set) var selectedItem: OZLListSelectorItem?
    fileprivate var transitionAnimator: OZLDropdownTransitionAnimator?

    fileprivate let ReuseIdentifier = "ReuseIdentifier"

    // MARK: Life cycle
    init(items: [OZLListSelectorItem], selectedItem: OZLListSelectorItem? = nil) {
        self.items = items
        self.selectedItem = selectedItem
        super.init(style: .plain)

        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier)
        self.tableView.rowHeight = 50.0
        self.tableView.isScrollEnabled = false
        self.tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        self.view.backgroundColor = UIColor.clear
        self.tableView.backgroundColor = UIColor.clear

        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: self.layoutMargin, bottom: 0, right: self.layoutMargin)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.reloadData()
        self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: self.tableView.contentSize.height)
    }

    // MARK: UITableViewDelegate/DataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier, for: indexPath)
        cell.textLabel?.text = item.title
        cell.textLabel?.textColor = UIColor.darkGray
        cell.backgroundColor = UIColor.clear
        cell.layoutMargins = UIEdgeInsets(top: 0, left: self.layoutMargin, bottom: 0, right: self.layoutMargin)

        let selectedBgView = UIView()
        selectedBgView.backgroundColor = UIColor.gray.withAlphaComponent(0.05)
        cell.selectedBackgroundView = selectedBgView

        if item.comparator == self.selectedItem?.comparator {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        self.delegate?.selector(self, didSelectItem: self.items[indexPath.row])
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    // MARK: Transitioning
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if let nav = source.navigationController {
            return OZLDropdownPresentationController(presentedViewController: presented,
                                                     presentingViewController: self,
                                                     navigationController: nav)
        }

        return nil
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let nav = source.navigationController {
            self.transitionAnimator = OZLDropdownTransitionAnimator(navigationController:nav)
            return self.transitionAnimator
        }

        return nil
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionAnimator?.presenting = false

        return self.transitionAnimator
    }
}
