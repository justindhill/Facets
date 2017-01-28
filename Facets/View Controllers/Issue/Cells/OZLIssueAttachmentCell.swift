//
//  OZLIssueAttachmentCell.swift
//  Facets
//
//  Created by Justin Hill on 5/12/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit
import SnapKit
import CircleProgressView
import SORelativeDateTransformer

class OZLIssueAttachmentCell: UITableViewCell {
    let attachmentTypeImageView = UIImageView()
    let attachmentTitleLabel = UILabel()
    let userIconImageView = UIImageView()
    let userNameLabel = UILabel()
    let timeIconImageView = UIImageView()
    let timeLabel = UILabel()
    let downloadButton = UIButton(type: .system)
    let progressView = CircleProgressView(frame: CGRect(x: 0, y: 0, width: 23, height: 23))

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.preservesSuperviewLayoutMargins = true
        self.contentView.preservesSuperviewLayoutMargins = true

        self.userIconImageView.contentMode = .center
        self.userIconImageView.image = UIImage(named: "icon-user")
        self.attachmentTypeImageView.contentMode = .center
        self.attachmentTypeImageView.image = UIImage(named: "icon-filetype-unknown")
        self.timeIconImageView.contentMode = .center
        self.timeIconImageView.image = UIImage(named: "icon-clock")

        self.progressView.trackWidth = 1.0
        self.progressView.centerFillColor = UIColor.white
        self.progressView.backgroundColor = UIColor.clear
        self.progressView.trackBackgroundColor = UIColor.lightGray

        self.downloadButton.setImage(UIImage(named: "icon-download"), for: UIControlState())
        self.downloadButton.imageView?.contentMode = .center
        self.downloadButton.sizeToFit()
        self.accessoryView = self.downloadButton

        self.userIconImageView.tintColor = UIColor.gray
        self.attachmentTypeImageView.tintColor = UIColor.darkGray
        self.timeIconImageView.tintColor = UIColor.gray

        self.attachmentTitleLabel.textColor = UIColor.darkGray
        self.userNameLabel.textColor = UIColor.gray
        self.timeLabel.textColor = UIColor.gray

        self.attachmentTitleLabel.text = "NotificationCounterNotUpdated.mp4"
        self.userNameLabel.text = "Timur Rahmanov"
        self.timeLabel.text = "3d"

        self.contentView.addSubview(self.attachmentTypeImageView)
        self.contentView.addSubview(self.attachmentTitleLabel)
        self.contentView.addSubview(self.userIconImageView)
        self.contentView.addSubview(self.userNameLabel)
        self.contentView.addSubview(self.timeIconImageView)
        self.contentView.addSubview(self.timeLabel)

        NotificationCenter.default.addObserver(self, selector: #selector(preferredContentSizeCategoryDidChange), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        self.preferredContentSizeCategoryDidChange()

        self.installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func installConstraints() {
        let horizontalElementSpacing = 8.0
        let verticalElementSpacing = 3.0
        let intraItemHorizontalSpacing = 3.0

        self.attachmentTypeImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.leading.equalTo(self.contentView.snp.leadingMargin)
            make.width.equalTo(28.0)
        }

        self.attachmentTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView.snp.top).offset(5)
            make.leading.equalTo(self.attachmentTypeImageView.snp.trailing).offset(horizontalElementSpacing)
            make.trailing.lessThanOrEqualTo(self.contentView.snp.trailingMargin)
        }

        self.userIconImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(self.attachmentTypeImageView.snp.trailing).offset(horizontalElementSpacing)
            make.width.equalTo(10.0)
            make.height.equalTo(10.0)
            make.centerY.equalTo(self.userNameLabel)
        }

        // Defines the bottom edge for automatic cell height computation
        self.userNameLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        self.userNameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.userIconImageView.snp.trailing).offset(intraItemHorizontalSpacing)
            make.top.equalTo(self.attachmentTitleLabel.snp.bottom).offset(verticalElementSpacing)
            make.bottom.lessThanOrEqualTo(self.contentView.snp.bottom).offset(-5)
        }

        self.timeIconImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(self.userNameLabel.snp.trailing).offset(horizontalElementSpacing)
            make.width.equalTo(10.0)
            make.height.equalTo(10.0)
            make.centerY.equalTo(self.timeLabel)
        }

        self.timeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.timeIconImageView.snp.trailing).offset(intraItemHorizontalSpacing)
            make.trailing.lessThanOrEqualTo(self.contentView.snp.trailingMargin).offset(-horizontalElementSpacing)
            make.top.equalTo(self.attachmentTitleLabel.snp.bottom).offset(verticalElementSpacing)
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.progressView.trackFillColor = self.tintColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryView = self.downloadButton
    }

    func preferredContentSizeCategoryDidChange() {
        self.attachmentTitleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        self.userNameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
        self.timeLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
        self.setNeedsLayout()
    }

    func applyAttachmentModel(_ attachment: OZLModelAttachment) {
        self.attachmentTitleLabel.text = attachment.name
        self.userNameLabel.text = attachment.attacher.name

        if let relativeDate = SORelativeDateTransformer.registeredTransformer().transformedValue(attachment.creationDate) as? String {
            self.timeLabel.text = relativeDate
        }

        self.attachmentTypeImageView.image = UIImage(named: attachment.fileClassificationImageName)
    }
}
