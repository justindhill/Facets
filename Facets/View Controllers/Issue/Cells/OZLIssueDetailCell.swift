//
//  OZLIssueDetailCell.swift
//  Facets
//
//  Created by Justin Hill on 5/28/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLIssueDetailCell: UITableViewCell {

    enum CellPosition {
        case top
        case middle
        case bottom
    }

    override var frame: CGRect {
        didSet {
            self.updateCornerRadiiForCellPosition(cellPosition)
        }
    }

    fileprivate(set) var detailNameLabel = UILabel()
    fileprivate(set) var accessoryImageView = UIImageView()
    fileprivate(set) var backdropLayer = CAShapeLayer()

    var pinned = false {
        didSet {
            self.backdropLayer.fillColor = pinned ? self.pinnedBackgroundColor.cgColor : self.unpinnedBackgroundColor.cgColor
        }
    }

    fileprivate let supplementalIndent: CGFloat = 16.0

    var unpinnedBackgroundColor: UIColor = UIColor.white {
        didSet {
            if !self.pinned {
                self.backdropLayer.fillColor = unpinnedBackgroundColor.cgColor
            }
        }
    }

    var pinnedBackgroundColor: UIColor = UIColor.ozlVeryLightGray() {
        didSet {
            if self.pinned {
                self.backdropLayer.fillColor = pinnedBackgroundColor.cgColor
            }
        }
    }

    var cellPosition: CellPosition = .top {
        didSet {
            self.updateCornerRadiiForCellPosition(cellPosition)
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backdropLayer.strokeColor = UIColor.lightGray.cgColor
        self.backdropLayer.fillColor = self.unpinnedBackgroundColor.cgColor

        self.detailNameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        self.detailNameLabel.backgroundColor = UIColor.clear

        self.contentView.layer.insertSublayer(self.backdropLayer, at: 0)
        self.contentView.addSubview(self.detailNameLabel)
        self.contentView.addSubview(self.accessoryImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateCornerRadiiForCellPosition(_ cellPosition: CellPosition) {
        var corners: UIRectCorner!

        switch cellPosition {
            case .top: corners = [.topLeft, .topRight]
            case .middle: corners = UIRectCorner()
            case .bottom: corners = [.bottomLeft, .bottomRight]
        }

        let realWidth = self.layer.bounds.size.width - self.layoutMargins.left - self.layoutMargins.right

        let pathRect = CGRect(
            x: self.layoutMargins.left,
            y: 0,
            width: realWidth,
            height: self.bounds.size.height
        )

        backdropLayer.path = UIBezierPath(
            roundedRect: pathRect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 3.0, height: 3.0)
        ).cgPath
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let contentBounds = self.contentView.bounds

        var maxLabelWidth = contentBounds.size.width - self.layoutMargins.left - self.layoutMargins.right - (2 * self.supplementalIndent)

        self.accessoryImageView.isHidden = (self.accessoryImageView.image == nil)

        if !self.accessoryImageView.isHidden {
            self.accessoryImageView.sizeToFit()
            self.accessoryImageView.frame.origin.x = contentBounds.size.width - self.layoutMargins.right - self.accessoryImageView.frame.size.width - self.supplementalIndent
            self.accessoryImageView.frame.origin.y = (contentBounds.size.height - self.accessoryImageView.frame.size.height) / 2.0

            maxLabelWidth -= (self.accessoryImageView.frame.size.width + 8)
        }

        self.detailNameLabel.sizeToFit()
        self.detailNameLabel.frame.origin.x = self.layoutMargins.left + self.supplementalIndent
        self.detailNameLabel.frame.origin.y = 0
        self.detailNameLabel.frame.size.height = contentBounds.height

        self.detailNameLabel.frame.size.width = min(self.detailNameLabel.frame.size.width, maxLabelWidth)
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        self.backdropLayer.lineWidth = (1.0 / self.traitCollection.displayScale)
        self.backdropLayer.frame = self.contentView.bounds
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backdropLayer.fillColor = (highlighted || self.pinned) ? self.pinnedBackgroundColor.cgColor : self.unpinnedBackgroundColor.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.setHighlighted(selected, animated: animated)
    }
}
