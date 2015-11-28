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
        
        let detailAttributes = [
            NSForegroundColorAttributeName: UIColor.darkGrayColor(),
            NSFontAttributeName: OZLJournalCell.detailFont,
            NSParagraphStyleAttributeName: detailPara
        ]
        
        for (index, detail) in details.enumerate() {
            var detailString: String!
            
            if let name = detail.displayName, let old = detail.oldValue, let new = detail.newValue {
                if old.characters.count > 20 || new.characters.count > 20 {
                    detailString  = "Updated \(name)"
                } else {
                    detailString = "Changed \(name): \(old) -> \(new)"
                    str.appendAttributedString(NSAttributedString(string: detailString, attributes:  detailAttributes))
                }
                
            } else if let name = detail.displayName, let new = detail.newValue {
                detailString  = "Set \(name) to \(new)"
                
            } else if detail.oldValue != nil, let name = detail.displayName {
                detailString  = "Removed \(name)"
            }
            
            str.appendAttributedString(NSAttributedString(string: detailString, attributes:  detailAttributes))
            
            if index < details.count - 1 || (index == details.count - 1 && note?.characters.count > 0) {
                str.appendAttributedString(NSAttributedString(string: "\n", attributes: detailAttributes))
            }
        }
        
        if let note = note {
            let noteAttributes = [
                NSForegroundColorAttributeName: UIColor.darkGrayColor(),
                NSFontAttributeName: OZLJournalCell.commentFont
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
