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
    
    private static let detailFont = UIFont.italicSystemFontOfSize(12.0)
    private static let commentFont = UIFont.systemFontOfSize(12.0)
    private static let dateFont = UIFont.systemFontOfSize(10.0)
    private static let authorFont = UIFont.OZLMediumSystemFontOfSize(12.0)
    
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
        
        self.usernameLabel.font = OZLJournalCell.authorFont
        self.usernameLabel.textColor = UIColor.darkGrayColor()
        
        self.dateLabel.font = OZLJournalCell.dateFont
        self.dateLabel.textColor = UIColor.lightGrayColor()
        
        self.commentLabel.font = OZLJournalCell.commentFont
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
        
        self.profileImageView.frame = CGRectMake(ceil(self.contentPadding),
            ceil(self.contentPadding / 2.0),
            OZLJournalCell.profileSideLen,
            OZLJournalCell.profileSideLen)
        
        self.usernameLabel.sizeToFit()
        self.dateLabel.sizeToFit()
        
        self.usernameLabel.frame.origin.x = ceil(self.profileImageView.right + 6.0)
        self.usernameLabel.frame.origin.y = ceil(self.profileImageView.top)
        
        self.dateLabel.frame.origin.x = self.usernameLabel.left
        self.dateLabel.frame.origin.y = ceil(self.usernameLabel.bottom + 2.0)
        
        self.commentLabel.frame.size.width = self.frame.size.width - self.profileImageView.right - self.contentPadding - 6.0
        self.commentLabel.sizeToFit()
        self.commentLabel.frame.origin.x = dateLabel.left
        self.commentLabel.frame.origin.y = ceil(dateLabel.bottom + 6.0)
    }
    
    private func applyJournalModel(journal: OZLModelJournal) {
        self.usernameLabel.text = journal.author?.name
        
        if let date = journal.creationDate {
            self.dateLabel.text = OZLJournalCell.dateFormatter.stringFromDate(date)
        } else {
            self.dateLabel.text = nil
        }
        
        if journal.details.count > 0 {
            self.commentLabel.attributedText = self.composeDetails(journal.details, note: journal.notes)
        } else {
            self.commentLabel.text = journal.notes
        }
    }
    
    private func composeDetails(details: Array<OZLModelJournalDetail>, note: String?) -> NSAttributedString {
        let str = NSMutableAttributedString()
        
        let detailPara = NSMutableParagraphStyle()
        detailPara.lineHeightMultiple = 1.15
        detailPara.lineBreakMode = .ByWordWrapping
        
        let detailAttributes = [
            NSForegroundColorAttributeName: UIColor.darkGrayColor(),
            NSFontAttributeName: OZLJournalCell.detailFont,
            NSParagraphStyleAttributeName: detailPara
        ]
        
        for (index, detail) in details.enumerate() {
            var detailString: String!
            
            if let name = detail.displayName, let old = detail.displayOldValue, let new = detail.displayNewValue {
                if old.characters.count > 20 || new.characters.count > 20 {
                    detailString  = "Updated \(name.lowercaseString)"
                } else {
                    detailString = "Changed \(name.lowercaseString): \(old) → \(new)"
                }
                
            } else if let name = detail.displayName, let new = detail.displayNewValue {
                if detail.type == .Attachment {
                    detailString  = "Added attachment (\(new))"
                } else {
                    if (new.characters.count > 20) {
                        detailString = "Set \(name.lowercaseString) (value too long to be displayed)"
                    } else {
                        detailString = "Set \(name.lowercaseString) to \(new)"
                    }
                }
                
            } else if let oldValue = detail.oldValue, let name = detail.displayName {
                if detail.type == .Attachment {
                    detailString = "Removed attachment (\(oldValue))"
                } else {
                    detailString  = "Removed \(name.lowercaseString)"
                }
            } else {
                // This should never happen, but let's cover our bases.
                detailString = ""
            }
            
            str.appendAttributedString(NSAttributedString(string: detailString, attributes:  detailAttributes))
            
            if index < details.count - 1 || (index == details.count - 1 && note?.characters.count > 0) {
                str.appendAttributedString(NSAttributedString(string: "\n", attributes: detailAttributes))
            }
        }
        
        if let note = note {
            let commentPara = NSMutableParagraphStyle()
            commentPara.lineHeightMultiple = 1.15
            commentPara.lineBreakMode = .ByWordWrapping
            
            let noteAttributes = [
                NSForegroundColorAttributeName: UIColor.darkGrayColor(),
                NSFontAttributeName: OZLJournalCell.commentFont,
                NSParagraphStyleAttributeName: commentPara
            ]
            
            str.appendAttributedString(NSAttributedString(string: note, attributes: noteAttributes))
        }
        
        return str
    }
    
    private static let sizingCell = OZLJournalCell(frame: CGRectZero)
    @objc class func heightWithWidth(width: CGFloat, contentPadding: CGFloat, journalModel: OZLModelJournal) -> CGFloat {
        sizingCell.frame.size.width = width
        
        if journalModel.notes?.characters.count > 0 || journalModel.details.count > 0 {
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
