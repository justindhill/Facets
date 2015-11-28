//
//  OZLJournalCell.swift
//  Facets
//
//  Created by Justin Hill on 11/27/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

class OZLJournalCell: OZLTableViewCell {

    private static let profileSideLen: CGFloat = 28.0
    private static let dateFormatter = NSDateFormatter()
    
    let profileImageView = UIImageView()
    let usernameLabel = UILabel()
    let dateLabel = UILabel()
    let commentLabel = UILabel()
    var isFirstLayout = true
    
    var journal: OZLModelJournal? = nil {
        didSet {
            if let journal = journal {
                self.applyJournalModel(journal)
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private static var dateOnceToken: dispatch_once_t = 0
    private func setup() {
        dispatch_once(&OZLJournalCell.dateOnceToken) { () -> Void in
            OZLJournalCell.dateFormatter.dateStyle = .ShortStyle
            OZLJournalCell.dateFormatter.timeStyle = .ShortStyle
        }
        
        self.profileImageView.layer.cornerRadius = OZLJournalCell.profileSideLen / 2.0
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.backgroundColor = UIColor.lightGrayColor()
        
        self.usernameLabel.font = UIFont.OZLMediumSystemFontOfSize(12.0)
        self.usernameLabel.textColor = UIColor.darkGrayColor()
        
        self.dateLabel.font = UIFont.systemFontOfSize(10.0)
        self.dateLabel.textColor = UIColor.lightGrayColor()
        
        self.commentLabel.font = UIFont.systemFontOfSize(12.0)
        self.commentLabel.numberOfLines = 0
        self.commentLabel.textColor = UIColor.darkGrayColor()
    }
    
    override func layoutSubviews() {
        if self.isFirstLayout {
            self.contentView.addSubview(self.profileImageView)
            self.contentView.addSubview(self.usernameLabel)
            self.contentView.addSubview(self.dateLabel)
            self.contentView.addSubview(self.commentLabel)
            
            self.isFirstLayout = false
        }
        
        self.profileImageView.frame = CGRectMake(self.contentPadding,
            self.contentPadding / 2.0,
            OZLJournalCell.profileSideLen,
            OZLJournalCell.profileSideLen)
        
        self.usernameLabel.sizeToFit()
        self.dateLabel.sizeToFit()
        
        self.usernameLabel.frame.origin.x = self.profileImageView.right + 6.0
        self.usernameLabel.frame.origin.y = self.profileImageView.top
        
        self.dateLabel.frame.origin.x = self.usernameLabel.left
        self.dateLabel.frame.origin.y = self.usernameLabel.bottom + 2.0
        
        self.commentLabel.frame.size.width = self.frame.size.width - self.profileImageView.right - self.contentPadding - 6.0
        self.commentLabel.sizeToFit()
        self.commentLabel.frame.origin.x = dateLabel.left
        self.commentLabel.frame.origin.y = dateLabel.bottom + 6.0
    }
    
    private func applyJournalModel(journal: OZLModelJournal) {
        self.usernameLabel.text = journal.author?.name
        
        if let date = journal.creationDate {
            self.dateLabel.text = OZLJournalCell.dateFormatter.stringFromDate(date)
        } else {
            self.dateLabel.text = nil
        }
        
        self.commentLabel.text = journal.notes
    }
    
    private static let sizingCell = OZLJournalCell(frame: CGRectZero)
    @objc class func heightWithWidth(width: CGFloat, contentPadding: CGFloat, journalModel: OZLModelJournal) -> CGFloat {
        sizingCell.frame.size.width = width
        
        if journalModel.notes?.characters.count > 0 {
            sizingCell.contentPadding = contentPadding
            sizingCell.journal = journalModel
            sizingCell.layoutSubviews()
            
            return sizingCell.commentLabel.bottom + contentPadding
            
        } else {
            sizingCell.layoutSubviews()
            
            return sizingCell.profileImageView.bottom + contentPadding
        }
    }
}
