//
//  OZLJournalCell.swift
//  Facets
//
//  Created by Justin Hill on 11/27/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class OZLJournalCell: UITableViewCell {

    private static var __once: () = { () -> Void in
            OZLJournalCell.dateFormatter.dateStyle = .short
            OZLJournalCell.dateFormatter.timeStyle = .short
        }()

    fileprivate static let profileSideLen: CGFloat = 28.0
    fileprivate static let dateFormatter = DateFormatter()
    
    fileprivate static let detailFont = UIFont.italicSystemFont(ofSize: 12.0)
    fileprivate static let commentFont = UIFont.systemFont(ofSize: 12.0)
    fileprivate static let dateFont = UIFont.systemFont(ofSize: 10.0)
    fileprivate static let authorFont = UIFont.ozlMediumSystemFont(ofSize: 12.0)
    
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
    
    fileprivate static var dateOnceToken: Int = 0
    fileprivate func setup() {
        _ = OZLJournalCell.__once
        
        self.profileImageView.layer.cornerRadius = OZLJournalCell.profileSideLen / 2.0
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.backgroundColor = UIColor.lightGray
        
        self.usernameLabel.font = OZLJournalCell.authorFont
        self.usernameLabel.textColor = UIColor.darkGray
        
        self.dateLabel.font = OZLJournalCell.dateFont
        self.dateLabel.textColor = UIColor.lightGray
        
        self.commentLabel.font = OZLJournalCell.commentFont
        self.commentLabel.numberOfLines = 0
        self.commentLabel.textColor = UIColor.darkGray
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.isFirstLayout {
            self.contentView.addSubview(self.profileImageView)
            self.contentView.addSubview(self.usernameLabel)
            self.contentView.addSubview(self.dateLabel)
            self.contentView.addSubview(self.commentLabel)
            
            self.isFirstLayout = false
        }
        
        self.profileImageView.frame = CGRect(x: self.layoutMargins.left,
            y: self.layoutMargins.top,
            width: OZLJournalCell.profileSideLen,
            height: OZLJournalCell.profileSideLen)
        
        self.usernameLabel.sizeToFit()
        self.dateLabel.sizeToFit()
        
        self.usernameLabel.frame.origin.x = ceil(self.profileImageView.right + 6.0)
        self.usernameLabel.frame.origin.y = ceil(self.profileImageView.top)
        
        self.dateLabel.frame.origin.x = self.usernameLabel.left
        self.dateLabel.frame.origin.y = ceil(self.usernameLabel.bottom + 2.0)
        
        self.commentLabel.frame.size.width = self.frame.size.width - self.profileImageView.right - self.layoutMargins.right - 6.0
        self.commentLabel.sizeToFit()
        self.commentLabel.frame.origin.x = dateLabel.left
        self.commentLabel.frame.origin.y = ceil(dateLabel.bottom + 6.0)
    }
    
    fileprivate func applyJournalModel(_ journal: OZLModelJournal) {
        self.usernameLabel.text = journal.author?.name
        
        if let date = journal.creationDate {
            self.dateLabel.text = OZLJournalCell.dateFormatter.string(from: date as Date)
        } else {
            self.dateLabel.text = nil
        }
        
        if journal.details.count > 0 {
            self.commentLabel.attributedText = self.composeDetails(journal.details, note: journal.notes)
        } else {
            self.commentLabel.text = journal.notes
        }
    }
    
    fileprivate func composeDetails(_ details: Array<OZLModelJournalDetail>, note: String?) -> NSAttributedString {
        let str = NSMutableAttributedString()
        
        let detailPara = NSMutableParagraphStyle()
        detailPara.lineHeightMultiple = 1.15
        detailPara.lineBreakMode = .byWordWrapping
        
        let detailAttributes = [
            NSForegroundColorAttributeName: UIColor.darkGray,
            NSFontAttributeName: OZLJournalCell.detailFont,
            NSParagraphStyleAttributeName: detailPara
        ]
        
        for (index, detail) in details.enumerated() {
            var detailString: String!
            
            if let name = detail.displayName, let old = detail.displayOldValue, let new = detail.displayNewValue {
                if old.characters.count > 20 || new.characters.count > 20 {
                    detailString  = "Updated \(name.lowercased())"
                } else {
                    detailString = "Changed \(name.lowercased()): \(old) → \(new)"
                }
                
            } else if let name = detail.displayName, let new = detail.displayNewValue {
                if detail.type == .attachment {
                    detailString  = "Added attachment (\(new))"
                } else {
                    if (new.characters.count > 20) {
                        detailString = "Set \(name.lowercased()) (value too long to be displayed)"
                    } else {
                        detailString = "Set \(name.lowercased()) to \(new)"
                    }
                }
                
            } else if let oldValue = detail.oldValue, let name = detail.displayName {
                if detail.type == .attachment {
                    detailString = "Removed attachment (\(oldValue))"
                } else {
                    detailString  = "Removed \(name.lowercased())"
                }
            } else {
                // This should never happen, but let's cover our bases.
                detailString = ""
            }
            
            str.append(NSAttributedString(string: detailString, attributes:  detailAttributes))
            
            if index < details.count - 1 || (index == details.count - 1 && note?.characters.count > 0) {
                str.append(NSAttributedString(string: "\n", attributes: detailAttributes))
            }
        }
        
        if let note = note {
            let commentPara = NSMutableParagraphStyle()
            commentPara.lineHeightMultiple = 1.15
            commentPara.lineBreakMode = .byWordWrapping
            
            let noteAttributes = [
                NSForegroundColorAttributeName: UIColor.darkGray,
                NSFontAttributeName: OZLJournalCell.commentFont,
                NSParagraphStyleAttributeName: commentPara
            ]
            
            str.append(NSAttributedString(string: note, attributes: noteAttributes))
        }
        
        return str
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        self.setNeedsLayout()
        self.layoutIfNeeded()

        var bottom: CGFloat = 0

        if self.commentLabel.text?.characters.count > 0 {
            bottom = self.commentLabel.bottom + self.layoutMargins.bottom
        } else {
            bottom = self.profileImageView.bottom + self.layoutMargins.bottom
        }

        return CGSize(width: targetSize.width, height: bottom)
    }
}
