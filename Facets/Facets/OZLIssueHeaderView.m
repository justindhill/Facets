//
//  OZLIssueHeaderView.m
//  Facets
//
//  Created by Justin Hill on 11/5/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLIssueHeaderView.h"

const NSInteger contentPadding = 16.;
const CGFloat profileSideLen = 32;

@interface OZLIssueHeaderView ()

@property BOOL isFirstLayout;
@property UILabel *assigneeTextLabel;

@end

@implementation OZLIssueHeaderView

- (instancetype)init {
    if (self = [super init]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.font = [UIFont OZLMediumSystemFontOfSize:17];
        
        self.assigneeProfileImageView = [[UIImageView alloc] init];
        self.assigneeProfileImageView.backgroundColor = [UIColor lightGrayColor];
        self.assigneeProfileImageView.layer.cornerRadius = (profileSideLen / 2.);
        self.assigneeProfileImageView.layer.masksToBounds = YES;
        
        self.assigneeTextLabel = [[UILabel alloc] init];
        self.assigneeTextLabel.text = @"ASSIGNEE";
        self.assigneeTextLabel.font = [UIFont systemFontOfSize:10];
        self.assigneeTextLabel.textColor = [UIColor lightGrayColor];
        
        self.assigneeDisplayNameLabel = [[UILabel alloc] init];
        self.assigneeDisplayNameLabel.font = [UIFont systemFontOfSize:14];
        
        self.isFirstLayout = YES;
    }
    
    return self;
}

- (void)layoutSubviews {
    if (self.isFirstLayout) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.assigneeProfileImageView];
        [self addSubview:self.assigneeTextLabel];
        [self addSubview:self.assigneeDisplayNameLabel];
    }
    
    self.titleLabel.preferredMaxLayoutWidth = self.frame.size.width - (2 * contentPadding);
    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(self.frame.size.width - (2 * contentPadding), CGFLOAT_MAX)];
    self.titleLabel.frame = (CGRect){{contentPadding, contentPadding}, size};
    
    self.assigneeProfileImageView.frame = CGRectMake(contentPadding, self.titleLabel.bottom + 12, profileSideLen, profileSideLen);
    
    [self.assigneeTextLabel sizeToFit];
    self.assigneeTextLabel.frame = (CGRect){{self.assigneeProfileImageView.right + 5, self.assigneeProfileImageView.top}, self.assigneeTextLabel.frame.size};
    
    [self.assigneeDisplayNameLabel sizeToFit];
    self.assigneeDisplayNameLabel.frame = (CGRect){{self.assigneeProfileImageView.right + 5, self.assigneeTextLabel.bottom + 3}, self.assigneeDisplayNameLabel.frame.size};
}

- (CGSize)sizeThatFits:(CGSize)size {
    self.frame = (CGRect){CGPointZero, size};
    [self layoutSubviews];
    
    return CGSizeMake(size.width, self.assigneeDisplayNameLabel.bottom + contentPadding);
}

@end
