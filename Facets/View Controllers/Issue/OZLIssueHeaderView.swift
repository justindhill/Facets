//
//  OZLIssueHeaderView.swift
//  Facets
//
//  Created by Justin Hill on 10/29/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit
import SDWebImage
import Jiramazing

class OZLIssueHeaderView: UIView {
    let profileSideLen: CGFloat = 32.0
    let assigneeTextSize: CGFloat = 14.0
    
    var isFirstLayout = true
    let assigneeTextLabel = UILabel()
    let titleLabel = UILabel()
    let assigneeDisplayNameLabel = UILabel()
    let assigneeProfileImageView = UIImageView()
    let assignButton = UIButton(type: .Custom)
    var contentPadding: CGFloat = 16.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = .ByWordWrapping
        self.titleLabel.font = UIFont.OZLMediumSystemFontOfSize(17)
        
        self.assigneeProfileImageView.backgroundColor = UIColor.lightGrayColor()
        self.assigneeProfileImageView.layer.cornerRadius = (profileSideLen / 2.0)
        self.assigneeProfileImageView.layer.masksToBounds = true
        
        self.assigneeTextLabel.text = "ASSIGNEE"
        self.assigneeTextLabel.font = UIFont.systemFontOfSize(10)
        self.assigneeTextLabel.textColor = UIColor.lightGrayColor()
        
        self.assigneeDisplayNameLabel.font = UIFont.systemFontOfSize(assigneeTextSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if self.isFirstLayout {
            self.isFirstLayout = false
            self.addSubview(self.titleLabel)
            self.addSubview(self.assigneeProfileImageView)
            self.addSubview(self.assigneeTextLabel)
            self.addSubview(self.assigneeDisplayNameLabel)
            self.addSubview(self.assignButton)
        }
        
        self.titleLabel.preferredMaxLayoutWidth = self.frame.size.width - (2 * self.contentPadding);
        self.titleLabel.frame.origin.x = self.contentPadding
        self.titleLabel.frame.origin.y = self.contentPadding
        self.titleLabel.frame.size = self.titleLabel.sizeThatFits(CGSizeMake(self.frame.size.width - (2 * self.contentPadding), CGFloat.max))
        
        self.assigneeProfileImageView.frame = CGRectMake(self.contentPadding, self.titleLabel.bottom + 12, profileSideLen, profileSideLen);
        
        self.assigneeTextLabel.sizeToFit()
        self.assigneeTextLabel.frame.origin.x = self.assigneeProfileImageView.right + 5
        self.assigneeTextLabel.frame.origin.y = self.assigneeProfileImageView.top
        
        self.assigneeDisplayNameLabel.sizeToFit()
        self.assigneeDisplayNameLabel.frame.origin.x = self.assigneeProfileImageView.right + 5
        self.assigneeDisplayNameLabel.frame.origin.y = self.assigneeTextLabel.bottom + 3
        
        self.assignButton.frame.origin = self.assigneeProfileImageView.frame.origin;
        self.assignButton.frame.size.width = max(self.assigneeTextLabel.right, self.assigneeDisplayNameLabel.right) - self.assigneeProfileImageView.left
        self.assignButton.frame.size.height = self.assigneeDisplayNameLabel.bottom - self.assigneeTextLabel.top
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        self.frame = CGRectMake(0, 0, size.width, size.height)
        self.layoutSubviews()
        
        return CGSizeMake(size.width, self.assigneeDisplayNameLabel.bottom + self.contentPadding);
    }
    
    func applyIssueModel(issue: Issue) {
        if let summary = issue.summary {
            self.titleLabel.attributedText = self.applyTitleAttributesToText(summary)
        } else {
            self.titleLabel.attributedText = nil
        }
        
        if let assignee = issue.assignee {
            self.assigneeDisplayNameLabel.font = UIFont.systemFontOfSize(assigneeTextSize)
            self.assigneeDisplayNameLabel.text = assignee.displayName;
            self.assigneeDisplayNameLabel.textColor = UIColor.blackColor()
            
        } else {
            self.assigneeDisplayNameLabel.font = UIFont.italicSystemFontOfSize(assigneeTextSize)
            self.assigneeDisplayNameLabel.text = "Tap to assign";
            self.assigneeDisplayNameLabel.textColor = UIColor.grayColor()
        }
        
        if let avatarUrl = issue.assignee?.avatarUrls?[.Large] {
            self.assigneeProfileImageView.sd_setImageWithURL(avatarUrl)
        } else {
            self.assigneeProfileImageView.sd_cancelCurrentImageLoad()
            self.assigneeProfileImageView.image = nil
        }
    }
    
    func applyTitleAttributesToText(text: String) -> NSAttributedString {
        let para = NSMutableParagraphStyle()
        para.lineHeightMultiple = 1.15
        
        let attr = NSAttributedString(string: text, attributes: [NSParagraphStyleAttributeName: para])
        
        return attr
    }
}
