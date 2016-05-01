//
//  OZLIssueTableViewCell.swift
//  Facets
//
//  Created by Justin Hill on 3/12/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit
import SORelativeDateTransformer

class OZLIssueTableViewCell: UITableViewCell {

    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var issueNumberLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var assigneeNameLabel: UILabel!
    @IBOutlet weak var assigneeAvatarImageView: UIImageView!
    @IBOutlet weak var dueDateLabel: UILabel!

    private class func cell() -> OZLIssueTableViewCell {
        let instance = UINib(nibName: "OZLIssueTableViewCell", bundle: NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil).first

        return instance as! OZLIssueTableViewCell
    }

    var contentPadding: CGFloat = 0.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.layer.shouldRasterize = true
        self.contentView.layer.rasterizationScale = UIScreen.mainScreen().scale

        self.priorityLabel.layer.masksToBounds = true
        self.assigneeAvatarImageView.layer.masksToBounds = true

        self.priorityLabel.textColor = UIColor.whiteColor()
        self.priorityLabel.backgroundColor = self.tintColor
        self.assigneeAvatarImageView.backgroundColor = UIColor.lightGrayColor()
    }

    func applyIssueModel(issue: OZLModelIssue) {
        self.priorityLabel.text = issue.priority?.name.uppercaseString;
        self.statusLabel.text = issue.status?.name.uppercaseString;
        self.issueNumberLabel.text = String(format: "#%d", issue.index)
        self.subjectLabel.text = issue.subject;

        self.assigneeNameLabel.hidden = (issue.assignedTo == nil)
        self.assigneeAvatarImageView.hidden = (issue.assignedTo == nil)
        self.dueDateLabel.hidden = (issue.dueDate == nil)

        if let assignee = issue.assignedTo {
            self.assigneeNameLabel.text = assignee.name.uppercaseString
        }

        if let dueDate = issue.dueDate {
            let relativeDate = SORelativeDateTransformer.registeredTransformer().transformedValue(dueDate.inSystemTimeZone())

            if let relativeDate = relativeDate {
                self.dueDateLabel.text = "due \(relativeDate)".uppercaseString
            }
        }

        self.setNeedsLayout()
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        if highlighted {
            self.contentView.backgroundColor = UIColor.OZLVeryLightGrayColor()
        } else {
            self.contentView.backgroundColor = UIColor.whiteColor()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        if selected {
            self.contentView.backgroundColor = UIColor.OZLVeryLightGrayColor()
        } else {
            self.contentView.backgroundColor = UIColor.whiteColor()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.priorityLabel.sizeToFit()
        self.priorityLabel.frame = CGRectMake(self.contentPadding,
                                              self.contentPadding,
                                              ceil(self.priorityLabel.frame.size.width + 6),
                                              ceil(self.priorityLabel.frame.size.height + 4))

        self.statusLabel.sizeToFit()
        self.statusLabel.frame = CGRectMake(floor(self.priorityLabel.right),
                                            self.priorityLabel.top,
                                            ceil(self.statusLabel.frame.size.width + 6),
                                            self.priorityLabel.frame.size.height)

        self.issueNumberLabel.sizeToFit()
        self.issueNumberLabel.frame = CGRectMake(ceil(self.statusLabel.right + (self.contentPadding / 2)),
                                                 self.statusLabel.top,
                                                 self.issueNumberLabel.frame.size.width,
                                                 self.priorityLabel.frame.size.height)

        self.subjectLabel.frame = CGRectMake(0, 0, self.contentView.frame.size.width - (2 * self.contentPadding), 0)
        self.subjectLabel.sizeToFit()
        self.subjectLabel.frame = CGRectMake(self.contentPadding,
                                             ceil(self.priorityLabel.bottom + (self.contentPadding / 2)),
                                             self.subjectLabel.frame.size.width,
                                             self.subjectLabel.frame.size.height)

        let bottomRowElementSpacing: CGFloat = 8.0
        let bottomRowElementYOffset: CGFloat = ceil(self.subjectLabel.bottom + (self.contentPadding / 2))
        let bottomRowElementHeight: CGFloat = 16.0

        if !self.assigneeNameLabel.hidden {

            self.assigneeAvatarImageView.frame = CGRectMake(self.contentPadding,
                                                            bottomRowElementYOffset,
                                                            bottomRowElementHeight,
                                                            bottomRowElementHeight)

            self.assigneeNameLabel.sizeToFit()
            self.assigneeNameLabel.frame = CGRectMake(ceil(self.contentPadding + bottomRowElementHeight + bottomRowElementSpacing),
                                                      bottomRowElementYOffset,
                                                      self.assigneeNameLabel.frame.size.width,
                                                      bottomRowElementHeight)


        }

        if !self.dueDateLabel.hidden {
            self.dueDateLabel.sizeToFit()

            if self.assigneeAvatarImageView.hidden {
                self.dueDateLabel.frame = CGRectMake(self.contentPadding,
                                                     bottomRowElementYOffset,
                                                     self.dueDateLabel.frame.size.width,
                                                     bottomRowElementHeight)
            } else {
                self.dueDateLabel.frame = CGRectMake(ceil(self.assigneeNameLabel.right + bottomRowElementSpacing),
                                                     bottomRowElementYOffset,
                                                     self.dueDateLabel.frame.size.width,
                                                     bottomRowElementHeight)
            }
        }
    }

    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)

        let leftRoundedMask = CAShapeLayer()
        leftRoundedMask.path = UIBezierPath(roundedRect: self.priorityLabel.bounds, byRoundingCorners: [.TopLeft, .BottomLeft], cornerRadii: CGSizeMake(2.0, 2.0)).CGPath

        self.priorityLabel.layer.mask = leftRoundedMask

        let rightRoundedMask = CAShapeLayer()
        rightRoundedMask.path = UIBezierPath(roundedRect: self.statusLabel.bounds, byRoundingCorners: [.TopRight, .BottomRight], cornerRadii: CGSizeMake(2.0, 2.0)).CGPath

        self.statusLabel.layer.mask = rightRoundedMask

        self.assigneeAvatarImageView.layer.cornerRadius = (self.assigneeAvatarImageView.frame.size.width / 2.0)
    }

    override func tintColorDidChange() {
        self.priorityLabel.backgroundColor = self.tintColor
    }

    private static let sizingInstance = OZLIssueTableViewCell.cell()
    class func heightWithWidth(width: CGFloat, issue: OZLModelIssue, contentPadding: CGFloat) -> CGFloat {
        let instance = OZLIssueTableViewCell.sizingInstance
        instance.frame = CGRectMake(0, 0, width, 0)
        instance.contentPadding = contentPadding
        instance.applyIssueModel(issue)
        instance.layoutSubviews()

        if !instance.dueDateLabel.hidden {
            return instance.dueDateLabel.bottom + contentPadding

        } else if !instance.assigneeAvatarImageView.hidden {
            return instance.assigneeAvatarImageView.bottom + contentPadding

        } else {
            return instance.subjectLabel.bottom + contentPadding
        }
    }
}
