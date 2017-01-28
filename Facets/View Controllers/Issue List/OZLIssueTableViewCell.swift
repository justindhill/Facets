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

    @IBOutlet weak var priorityPillSection: UIButton!
    @IBOutlet weak var statusPillSection: UIButton!
    @IBOutlet weak var issueNumberLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var assigneeNameLabel: UILabel!
    @IBOutlet weak var assigneeAvatarImageView: UIImageView!
    @IBOutlet weak var dueDateLabel: UILabel!

    fileprivate class func cell() -> OZLIssueTableViewCell {
        let instance = UINib(nibName: "OZLIssueTableViewCell", bundle: Bundle.main).instantiate(withOwner: nil, options: nil).first

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
        self.contentView.layer.rasterizationScale = UIScreen.main.scale

        self.priorityPillSection.isUserInteractionEnabled = false
        self.statusPillSection.isUserInteractionEnabled = false

        self.assigneeAvatarImageView.layer.masksToBounds = true

        self.priorityPillSection.setTitleColor(UIColor.white, for: UIControlState())
        self.assigneeAvatarImageView.backgroundColor = UIColor.lightGray

        let leftBgImage = self.cappedImageWithRoundedCorners(.left, cornerRadius: 2.0, height: 16.0).withRenderingMode(.alwaysTemplate)
        self.priorityPillSection.setBackgroundImage(leftBgImage, for: UIControlState())

        let rightBgImage = self.cappedImageWithRoundedCorners(.right, cornerRadius: 2.0, height: 16.0, color: UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1))
        self.statusPillSection.setBackgroundImage(rightBgImage, for: UIControlState())
    }

    func applyIssueModel(_ issue: OZLModelIssue) {
        self.priorityPillSection.setTitle(issue.priority?.name.uppercased(), for: .normal)
        self.statusPillSection.setTitle(issue.status?.name.uppercased(), for: .normal)
        self.issueNumberLabel.text = String(format: "#%d", issue.index)
        self.subjectLabel.text = issue.subject

        self.assigneeNameLabel.isHidden = (issue.assignedTo == nil)
        self.assigneeAvatarImageView.isHidden = (issue.assignedTo == nil)
        self.dueDateLabel.isHidden = (issue.dueDate == nil)

        if let assignee = issue.assignedTo {
            self.assigneeNameLabel.text = assignee.name.uppercased()
        }

        if let dueDate = issue.dueDate {
            let relativeDate = SORelativeDateTransformer.registeredTransformer().transformedValue(dueDate.inSystemTimeZone())

            if let relativeDate = relativeDate {
                self.dueDateLabel.text = "due \(relativeDate)".uppercased()
            }
        }

        self.setNeedsLayout()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.contentView.backgroundColor = UIColor.ozlVeryLightGray()
        } else {
            self.contentView.backgroundColor = UIColor.white
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.contentView.backgroundColor = UIColor.ozlVeryLightGray()
        } else {
            self.contentView.backgroundColor = UIColor.white
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.priorityPillSection.sizeToFit()
        self.priorityPillSection.frame = CGRect(x: self.contentPadding,
                                              y: self.contentPadding,
                                              width: ceil(self.priorityPillSection.frame.size.width + 6),
                                              height: ceil(self.priorityPillSection.frame.size.height + 4))

        self.statusPillSection.sizeToFit()
        self.statusPillSection.frame = CGRect(x: floor(self.priorityPillSection.right),
                                            y: self.priorityPillSection.top,
                                            width: ceil(self.statusPillSection.frame.size.width + 6),
                                            height: self.priorityPillSection.frame.size.height)

        self.issueNumberLabel.sizeToFit()
        self.issueNumberLabel.frame = CGRect(x: ceil(self.statusPillSection.right + (self.contentPadding / 2)),
                                                 y: self.statusPillSection.top,
                                                 width: self.issueNumberLabel.frame.size.width,
                                                 height: self.priorityPillSection.frame.size.height)

        self.subjectLabel.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.size.width - (2 * self.contentPadding), height: 0)
        self.subjectLabel.sizeToFit()
        self.subjectLabel.frame = CGRect(x: self.contentPadding,
                                             y: ceil(self.priorityPillSection.bottom + (self.contentPadding / 2)),
                                             width: self.subjectLabel.frame.size.width,
                                             height: self.subjectLabel.frame.size.height)

        let bottomRowElementSpacing: CGFloat = 8.0
        let bottomRowElementYOffset: CGFloat = ceil(self.subjectLabel.bottom + (self.contentPadding / 2))
        let bottomRowElementHeight: CGFloat = 16.0

        if !self.assigneeNameLabel.isHidden {

            self.assigneeAvatarImageView.frame = CGRect(x: self.contentPadding,
                                                            y: bottomRowElementYOffset,
                                                            width: bottomRowElementHeight,
                                                            height: bottomRowElementHeight)

            self.assigneeNameLabel.sizeToFit()
            self.assigneeNameLabel.frame = CGRect(x: ceil(self.contentPadding + bottomRowElementHeight + bottomRowElementSpacing),
                                                      y: bottomRowElementYOffset,
                                                      width: self.assigneeNameLabel.frame.size.width,
                                                      height: bottomRowElementHeight)


        }

        if !self.dueDateLabel.isHidden {
            self.dueDateLabel.sizeToFit()

            if self.assigneeAvatarImageView.isHidden {
                self.dueDateLabel.frame = CGRect(x: self.contentPadding,
                                                     y: bottomRowElementYOffset,
                                                     width: self.dueDateLabel.frame.size.width,
                                                     height: bottomRowElementHeight)
            } else {
                self.dueDateLabel.frame = CGRect(x: ceil(self.assigneeNameLabel.right + bottomRowElementSpacing),
                                                     y: bottomRowElementYOffset,
                                                     width: self.dueDateLabel.frame.size.width,
                                                     height: bottomRowElementHeight)
            }
        }
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        self.assigneeAvatarImageView.layer.cornerRadius = (self.assigneeAvatarImageView.frame.size.width / 2.0)
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {

        self.setNeedsLayout()
        self.layoutIfNeeded()

        var bottom: CGFloat = 0
        if !self.dueDateLabel.isHidden {
            bottom = self.dueDateLabel.bottom + self.layoutMargins.bottom

        } else if !self.assigneeAvatarImageView.isHidden {
            bottom = self.assigneeAvatarImageView.bottom + self.layoutMargins.bottom

        } else {
            bottom = self.subjectLabel.bottom + self.layoutMargins.bottom
        }

        return CGSize(width: targetSize.width, height: bottom)
    }

    // MARK: - Private
    fileprivate enum RoundedImageSide {
        case left
        case right
    }

    fileprivate func cappedImageWithRoundedCorners(_ side: RoundedImageSide, cornerRadius: CGFloat, height: CGFloat, color: UIColor = UIColor.black) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: cornerRadius + 1, height: max(height - (2 * cornerRadius), 2 * cornerRadius) + 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()

        var corners: UIRectCorner!
        if side == .left {
            corners = [.topLeft, .bottomLeft]
        } else {
            corners = [.topRight, .bottomRight]
        }

        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        color.setFill()
        ctx?.addPath(path)
        ctx?.fillPath()

        var image = UIGraphicsGetImageFromCurrentImageContext()

        if side == .left {
            image = image?.resizableImage(withCapInsets: UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, 1))
        } else {
            image = image?.resizableImage(withCapInsets: UIEdgeInsetsMake(cornerRadius, 1, cornerRadius, cornerRadius))
        }

        return image!
    }
}
