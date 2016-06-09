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
        case Top
        case Middle
        case Bottom
    }

    override var frame: CGRect {
        didSet {
            self.updateCornerRadiiForCellPosition(cellPosition)
        }
    }

    private(set) var detailNameLabel = UILabel()
    private(set) var accessoryImageView = UIImageView()
    private(set) var backdropLayer = CAShapeLayer()

    var pinned = false {
        didSet {
            self.backdropLayer.fillColor = pinned ? self.pinnedBackgroundColor.CGColor : self.unpinnedBackgroundColor.CGColor
        }
    }

    private let supplementalIndent: CGFloat = 16.0

    var unpinnedBackgroundColor: UIColor = UIColor.whiteColor() {
        didSet {
            if !self.pinned {
                self.backdropLayer.fillColor = unpinnedBackgroundColor.CGColor
            }
        }
    }

    var pinnedBackgroundColor: UIColor = UIColor.OZLVeryLightGrayColor() {
        didSet {
            if self.pinned {
                self.backdropLayer.fillColor = pinnedBackgroundColor.CGColor
            }
        }
    }

    var cellPosition: CellPosition = .Top {
        didSet {
            self.updateCornerRadiiForCellPosition(cellPosition)
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backdropLayer.strokeColor = UIColor.lightGrayColor().CGColor
        self.backdropLayer.fillColor = self.unpinnedBackgroundColor.CGColor

        self.detailNameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.detailNameLabel.backgroundColor = UIColor.clearColor()

        self.contentView.layer.insertSublayer(self.backdropLayer, atIndex: 0)
        self.contentView.addSubview(self.detailNameLabel)
        self.contentView.addSubview(self.accessoryImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateCornerRadiiForCellPosition(cellPosition: CellPosition) {
        var corners: UIRectCorner!

        switch cellPosition {
            case .Top: corners = [.TopLeft, .TopRight]
            case .Middle: corners = UIRectCorner()
            case .Bottom: corners = [.BottomLeft, .BottomRight]
        }

        let realWidth = self.layer.bounds.size.width - self.layoutMargins.left - self.layoutMargins.right

        let pathRect = CGRectMake(
            self.layoutMargins.left,
            0,
            realWidth,
            self.bounds.size.height
        )

        backdropLayer.path = UIBezierPath(
            roundedRect: pathRect,
            byRoundingCorners: corners,
            cornerRadii: CGSizeMake(3.0, 3.0)
        ).CGPath
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let contentBounds = self.contentView.bounds

        var maxLabelWidth = contentBounds.size.width - self.layoutMargins.left - self.layoutMargins.right - (2 * self.supplementalIndent)

        self.accessoryImageView.hidden = (self.accessoryImageView.image == nil)

        if !self.accessoryImageView.hidden {
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

    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)

        self.backdropLayer.lineWidth = (1.0 / self.traitCollection.displayScale)
        self.backdropLayer.frame = self.contentView.bounds
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        self.backdropLayer.fillColor = (highlighted || self.pinned) ? self.pinnedBackgroundColor.CGColor : self.unpinnedBackgroundColor.CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        self.setHighlighted(selected, animated: animated)
    }
}
