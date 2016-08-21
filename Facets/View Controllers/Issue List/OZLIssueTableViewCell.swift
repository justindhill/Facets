//
//  OZLIssueTableViewCell.swift
//  Facets
//
//  Created by Justin Hill on 3/12/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit
import SORelativeDateTransformer
import Jiramazing
import SDWebImage

class OZLIssueTableViewCell: UITableViewCell {

    @IBOutlet weak var priorityPillSection: UIButton!
    @IBOutlet weak var statusPillSection: UIButton!
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

        self.preservesSuperviewLayoutMargins = false

        self.contentView.layer.shouldRasterize = true
        self.contentView.layer.rasterizationScale = UIScreen.mainScreen().scale

        self.priorityPillSection.userInteractionEnabled = false
        self.statusPillSection.userInteractionEnabled = false

        self.assigneeAvatarImageView.layer.masksToBounds = true

        self.priorityPillSection.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.assigneeAvatarImageView.backgroundColor = UIColor.lightGrayColor()

        let leftBgImage = self.cappedImageWithRoundedCorners(.Left, cornerRadius: 2.0, height: 16.0).imageWithRenderingMode(.AlwaysTemplate)
        self.priorityPillSection.setBackgroundImage(leftBgImage, forState: .Normal)

        let rightBgImage = self.cappedImageWithRoundedCorners(.Right, cornerRadius: 2.0, height: 16.0, color: UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1))
        self.statusPillSection.setBackgroundImage(rightBgImage, forState: .Normal)
    }

    func applyIssueModel(issue: Issue) {
        self.priorityPillSection.setTitle(issue.priority?.name?.uppercaseString, forState: .Normal)
        self.statusPillSection.setTitle(issue.status?.name?.uppercaseString, forState: .Normal)
        self.issueNumberLabel.text = issue.key
        self.subjectLabel.text = issue.summary

        self.assigneeNameLabel.hidden = (issue.assignee == nil)
        self.assigneeAvatarImageView.hidden = (issue.assignee == nil)
        self.dueDateLabel.hidden = (issue.dueDate == nil)

        if let assignee = issue.assignee {
            self.assigneeNameLabel.text = assignee.displayName?.uppercaseString
            self.assigneeAvatarImageView.sd_setImageWithURL(issue.assignee?.avatarUrls?[.Medium])
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

        self.priorityPillSection.sizeToFit()
        self.priorityPillSection.frame = CGRectMake(self.contentPadding,
                                              self.contentPadding,
                                              ceil(self.priorityPillSection.frame.size.width + 6),
                                              ceil(self.priorityPillSection.frame.size.height + 4))

        self.statusPillSection.sizeToFit()
        self.statusPillSection.frame = CGRectMake(floor(self.priorityPillSection.right),
                                            self.priorityPillSection.top,
                                            ceil(self.statusPillSection.frame.size.width + 6),
                                            self.priorityPillSection.frame.size.height)

        self.issueNumberLabel.sizeToFit()
        self.issueNumberLabel.frame = CGRectMake(ceil(self.statusPillSection.right + (self.contentPadding / 2)),
                                                 self.statusPillSection.top,
                                                 self.issueNumberLabel.frame.size.width,
                                                 self.priorityPillSection.frame.size.height)

        self.subjectLabel.frame = CGRectMake(0, 0, self.contentView.frame.size.width - (2 * self.contentPadding), 0)
        self.subjectLabel.sizeToFit()
        self.subjectLabel.frame = CGRectMake(self.contentPadding,
                                             ceil(self.priorityPillSection.bottom + (self.contentPadding / 2)),
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

        self.assigneeAvatarImageView.layer.cornerRadius = (self.assigneeAvatarImageView.frame.size.width / 2.0)
    }

    override func systemLayoutSizeFittingSize(targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {

        self.setNeedsLayout()
        self.layoutIfNeeded()

        var bottom: CGFloat = 0
        if !self.dueDateLabel.hidden {
            bottom = self.dueDateLabel.bottom + self.layoutMargins.bottom

        } else if !self.assigneeAvatarImageView.hidden {
            bottom = self.assigneeAvatarImageView.bottom + self.layoutMargins.bottom

        } else {
            bottom = self.subjectLabel.bottom + self.layoutMargins.bottom
        }

        return CGSizeMake(targetSize.width, bottom)
    }

    // MARK: - Private
    private enum RoundedImageSide {
        case Left
        case Right
    }

    private func cappedImageWithRoundedCorners(side: RoundedImageSide, cornerRadius: CGFloat, height: CGFloat, color: UIColor = UIColor.blackColor()) -> UIImage {
        let rect = CGRectMake(0, 0, cornerRadius + 1, max(height - (2 * cornerRadius), 2 * cornerRadius) + 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()

        var corners: UIRectCorner!
        if side == .Left {
            corners = [.TopLeft, .BottomLeft]
        } else {
            corners = [.TopRight, .BottomRight]
        }

        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSizeMake(cornerRadius, cornerRadius)).CGPath
        color.setFill()
        CGContextAddPath(ctx, path)
        CGContextFillPath(ctx)

        var image = UIGraphicsGetImageFromCurrentImageContext()

        if side == .Left {
            image = image.resizableImageWithCapInsets(UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, 1))
        } else {
            image = image.resizableImageWithCapInsets(UIEdgeInsetsMake(cornerRadius, 1, cornerRadius, cornerRadius))
        }

        return image
    }

    override func prepareForReuse() {
        self.assigneeAvatarImageView.sd_cancelCurrentImageLoad()
        self.assigneeAvatarImageView.image = nil
    }
}
