//
//  OZLIssueAttachmentCell.swift
//  Facets
//
//  Created by Justin Hill on 5/12/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLIssueAttachmentCell: OZLTableViewCell {
    let attachmentTypeImageView = UIImageView()
    let attachmentTitleLabel = UILabel()
    let userIconImageView = UIImageView()
    let userNameLabel = UILabel()
    let timeIconImageView = UIImageView()
    let timeLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.userIconImageView.contentMode = .Center
        self.userIconImageView.image = UIImage(named: "icon-user")
        self.attachmentTypeImageView.contentMode = .Center
        self.attachmentTypeImageView.image = UIImage(named: "icon-filetype-photo")
        self.timeIconImageView.contentMode = .Center
        self.timeIconImageView.image = UIImage(named: "icon-clock")

        self.userIconImageView.tintColor = UIColor.grayColor()
        self.attachmentTypeImageView.tintColor = UIColor.darkGrayColor()
        self.timeIconImageView.tintColor = UIColor.grayColor()

        self.attachmentTitleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.userNameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        self.timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)

        self.attachmentTitleLabel.textColor = UIColor.darkGrayColor()
        self.userNameLabel.textColor = UIColor.grayColor()
        self.timeLabel.textColor = UIColor.grayColor()

        self.attachmentTitleLabel.text = "NotificationCounterNotUpdated.mp4"
        self.userNameLabel.text = "Timur Rahmanov"
        self.timeLabel.text = "3d"
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.attachmentTitleLabel.superview == nil {
            self.contentView.addSubview(self.attachmentTypeImageView)
            self.contentView.addSubview(self.attachmentTitleLabel)
            self.contentView.addSubview(self.userIconImageView)
            self.contentView.addSubview(self.userNameLabel)
            self.contentView.addSubview(self.timeIconImageView)
            self.contentView.addSubview(self.timeLabel)
        }

        self.attachmentTypeImageView.frame = CGRectMake(self.layoutMargins.left, 0, 28.0, self.frame.size.height)

        self.attachmentTitleLabel.sizeToFit()
        self.attachmentTitleLabel.frame.origin = CGPointMake(self.attachmentTypeImageView.right + 6, 6)

        self.userIconImageView.sizeToFit()
        self.userNameLabel.sizeToFit()
        self.timeIconImageView.sizeToFit()
        self.timeLabel.sizeToFit()

        self.userNameLabel.frame.origin = CGPointMake(self.attachmentTypeImageView.right + 6 + self.userIconImageView.frame.size.width + 3,
                                                      self.attachmentTitleLabel.bottom + 3)

        let bottomLineIconYOffset = ceil(((self.userNameLabel.frame.size.height - self.userIconImageView.frame.size.height) / 2.0) + self.userNameLabel.frame.origin.y)
        let userIconYOffset = bottomLineIconYOffset - 1.0

        self.userIconImageView.frame.origin = CGPointMake(self.attachmentTypeImageView.right + 6, userIconYOffset)

        self.timeIconImageView.frame.origin = CGPointMake(self.userNameLabel.right + 6, bottomLineIconYOffset)
        self.timeLabel.frame.origin = CGPointMake(self.timeIconImageView.right + 3, self.userNameLabel.frame.origin.y)

    }

    private static var sizingCell = OZLIssueAttachmentCell(style: .Default, reuseIdentifier: nil)
    override class func heightForWidth(width: CGFloat, model: NSObject!, layoutMargins: UIEdgeInsets) -> CGFloat {
        let sizingCell = OZLIssueAttachmentCell.sizingCell

        sizingCell.frame = CGRectMake(0, 0, width, 0)
        sizingCell.layoutMargins = layoutMargins
        sizingCell.layoutSubviews()

        return sizingCell.userNameLabel.bottom + 6
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
