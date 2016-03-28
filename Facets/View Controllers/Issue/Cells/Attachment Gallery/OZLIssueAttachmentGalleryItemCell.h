//
//  OZLIssueAttachmentGalleryItemCell.h
//  Facets
//
//  Created by Justin Hill on 11/14/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OZLModelAttachment.h"

@class OZLAsyncImageView;

@interface OZLIssueAttachmentGalleryItemCell : UICollectionViewCell

@property (nonatomic, strong) OZLModelAttachment *attachment;
@property (readonly) OZLAsyncImageView *thumbnailImageView;

@end
