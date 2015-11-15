//
//  OZLIssueAttachmentGalleryItemCell.m
//  Facets
//
//  Created by Justin Hill on 11/14/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLIssueAttachmentGalleryItemCell.h"

@interface OZLIssueAttachmentGalleryItemCell ()

@property BOOL isFirstLayout;
@property UILabel *typeLabel;
@property UIImageView *thumbnailImageView;

@end

@implementation OZLIssueAttachmentGalleryItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.isFirstLayout = YES;
        self.typeLabel = [[UILabel alloc] init];
        self.typeLabel.font = [UIFont systemFontOfSize:18.];
        self.typeLabel.textColor = [UIColor lightGrayColor];
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        self.thumbnailImageView = [[UIImageView alloc] init];
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        self.layer.borderWidth = 1.;
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)setAttachment:(OZLModelAttachment *)attachment {
    _attachment = attachment;
    
    NSString *type = [[attachment.contentType componentsSeparatedByString:@"/"] lastObject];
    self.typeLabel.text = type;
    
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:attachment.thumbnailURL]];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.isFirstLayout) {
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.thumbnailImageView];
    }
    
    [self.typeLabel sizeToFit];
    
    CGFloat xOffset = (self.contentView.frame.size.width - self.typeLabel.frame.size.width) / 2.;
    CGFloat yOffset = (self.contentView.frame.size.height - self.typeLabel.frame.size.height) / 2.;
    
    self.typeLabel.frame = (CGRect){{xOffset, yOffset}, self.typeLabel.frame.size};
    self.thumbnailImageView.frame = self.contentView.bounds;
    
    NSString *thumbnailURL = self.attachment.thumbnailURL;
    
    if (thumbnailURL && !self.thumbnailImageView.image) {
        [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:thumbnailURL]];
    }
    
    self.isFirstLayout = NO;
}

- (void)prepareForReuse {
    [self.thumbnailImageView cancelImageRequestOperation];
    self.thumbnailImageView.image = nil;
}

@end
