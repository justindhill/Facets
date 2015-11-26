//
//  OZLIssueAttachmentGalleryItemCell.m
//  Facets
//
//  Created by Justin Hill on 11/14/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLIssueAttachmentGalleryItemCell.h"
#import "Facets-Swift.h"

@interface OZLIssueAttachmentGalleryItemCell ()

@property BOOL isFirstLayout;
@property UILabel *typeLabel;
@property OZLAsyncImageView *thumbnailImageView;

@end

@implementation OZLIssueAttachmentGalleryItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.isFirstLayout = YES;
        self.typeLabel = [[UILabel alloc] init];
        self.typeLabel.font = [UIFont systemFontOfSize:12.];
        self.typeLabel.numberOfLines = 999.;
        self.typeLabel.textColor = [UIColor lightGrayColor];
        self.typeLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        self.thumbnailImageView = [[OZLAsyncImageView alloc] init];
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        self.layer.borderWidth = 1.;
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)setAttachment:(OZLModelAttachment *)attachment {
    _attachment = attachment;
    
    self.typeLabel.text = attachment.name;
    
    self.thumbnailImageView.url = [NSURL URLWithString:attachment.thumbnailURL];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.isFirstLayout) {
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.thumbnailImageView];
    }
    
    const CGFloat padding = 5.;
    
    self.typeLabel.frame = CGRectMake(0, 0, self.frame.size.width - (2 * padding), 0);
    
    [self.typeLabel sizeToFit];
    
    CGSize finalSize = self.typeLabel.frame.size;
    
    if (self.typeLabel.frame.size.height > self.frame.size.height - (2 * padding)) {
        finalSize.height = self.frame.size.height - (2 * padding);
    }
    
    CGFloat xOffset = (self.contentView.frame.size.width - finalSize.width) / 2.;
    CGFloat yOffset = (self.contentView.frame.size.height - finalSize.height) / 2.;
    
    self.typeLabel.frame = (CGRect){{xOffset, yOffset}, finalSize};
    self.thumbnailImageView.frame = self.contentView.bounds;
    
    NSString *thumbnailURL = self.attachment.thumbnailURL;
    
    if (thumbnailURL && !self.thumbnailImageView.image) {
        self.thumbnailImageView.url = [NSURL URLWithString:thumbnailURL];
    }
    
    self.isFirstLayout = NO;
}

- (void)prepareForReuse {
    self.thumbnailImageView.url = nil;
}

@end
