//
//  OZLIssueAttachmentGalleryCell.h
//  Facets
//
//  Created by Justin Hill on 11/14/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLTableViewCell.h"
#import "OZLModelAttachment.h"

@class OZLIssueAttachmentGalleryCell;
@protocol OZLIssueAttachmentGalleryCellDelegate <NSObject>

- (void)galleryCell:(OZLIssueAttachmentGalleryCell *)galleryCell didSelectAttachment:(OZLModelAttachment *)attachment withCellRelativeFrame:(CGRect)frame;

@end

@interface OZLIssueAttachmentGalleryCell : OZLTableViewCell

@property (weak) id <OZLIssueAttachmentGalleryCellDelegate> delegate;
@property (nonatomic, strong) NSArray<OZLModelAttachment *> *attachments;

@end
