//
//  OZLIssueAttachmentCell.swift
//  Facets
//
//  Created by Justin Hill on 5/12/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit
import SnapKit

class OZLIssueAttachmentCell: OZLTableViewCell {
    let attachmentTypeImageView = UIImageView()
    let attachmentTitleLabel = UILabel()
    let userIconImageView = UIImageView()
    let userNameLabel = UILabel()
    let timeIconImageView = UIImageView()
    let timeLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.preservesSuperviewLayoutMargins = false
        self.contentView.preservesSuperviewLayoutMargins = false
        self.contentView.layoutMargins = UIEdgeInsetsMake(5, OZLContentPadding, 5, OZLContentPadding)

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

        self.installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        print("before: \(NSStringFromUIEdgeInsets(self.layoutMargins))")
        super.layoutSubviews()
        print("after: \(NSStringFromUIEdgeInsets(self.layoutMargins))")
    }

    func installConstraints() {
        let horizontalElementSpacing = 8.0
        let verticalElementSpacing = 3.0
        let intraItemHorizontalSpacing = 3.0

        self.contentView.addSubview(self.attachmentTypeImageView)
        self.contentView.addSubview(self.attachmentTitleLabel)
        self.contentView.addSubview(self.userIconImageView)
        self.contentView.addSubview(self.userNameLabel)
        self.contentView.addSubview(self.timeIconImageView)
        self.contentView.addSubview(self.timeLabel)

        self.attachmentTypeImageView.snp_makeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.leading.equalTo(self.contentView.snp_leadingMargin)
            make.width.equalTo(28.0)
        }

        self.attachmentTitleLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.contentView.snp_topMargin)
            make.leading.equalTo(self.attachmentTypeImageView.snp_trailing).offset(horizontalElementSpacing)
            make.trailing.lessThanOrEqualTo(self.contentView.snp_trailingMargin)
        }

        self.userIconImageView.snp_makeConstraints { (make) in
            make.leading.equalTo(self.attachmentTypeImageView.snp_trailing).offset(horizontalElementSpacing)
            make.width.equalTo(10.0)
            make.height.equalTo(10.0)
            make.centerY.equalTo(self.userNameLabel)
        }

        // Defines the bottom edge for automatic cell height computation
        self.userNameLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        self.userNameLabel.snp_makeConstraints { (make) in
            make.leading.equalTo(self.userIconImageView.snp_trailing).offset(intraItemHorizontalSpacing)
            make.top.equalTo(self.attachmentTitleLabel.snp_bottom).offset(verticalElementSpacing)
            make.bottom.lessThanOrEqualTo(self.contentView.snp_bottomMargin)
        }

        self.timeIconImageView.snp_makeConstraints { (make) in
            make.leading.equalTo(self.userNameLabel.snp_trailing).offset(horizontalElementSpacing)
            make.width.equalTo(10.0)
            make.height.equalTo(10.0)
            make.centerY.equalTo(self.timeLabel)
        }

        self.timeLabel.snp_makeConstraints { (make) in
            make.leading.equalTo(self.timeIconImageView.snp_trailing).offset(intraItemHorizontalSpacing)
            make.trailing.lessThanOrEqualTo(self.contentView.snp_trailingMargin)
            make.top.equalTo(self.attachmentTitleLabel.snp_bottom).offset(verticalElementSpacing)
        }
    }
}
