//
//  OZLIssueHeaderView.m
//  Facets
//
//  Created by Justin Hill on 11/5/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLIssueHeaderView.h"
#import "Facets-Swift.h"

const CGFloat profileSideLen = 32.;
const CGFloat assigneeTextSize = 14.;

@interface OZLIssueHeaderView ()

@property BOOL isFirstLayout;
@property UILabel *assigneeTextLabel;

@end

@implementation OZLIssueHeaderView

#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super init]) {
        self.contentPadding = 16.;
        
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
        self.assigneeTextLabel.font = [UIFont systemFontOfSize:10.];
        self.assigneeTextLabel.textColor = [UIColor lightGrayColor];
        
        self.assigneeDisplayNameLabel = [[UILabel alloc] init];
        self.assigneeDisplayNameLabel.font = [UIFont systemFontOfSize:assigneeTextSize];
        
        self.assignButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        self.isFirstLayout = YES;
    }
    
    return self;
}

#pragma mark - Layout
- (void)layoutSubviews {
    if (self.isFirstLayout) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.assigneeProfileImageView];
        [self addSubview:self.assigneeTextLabel];
        [self addSubview:self.assigneeDisplayNameLabel];
        [self addSubview:self.assignButton];
    }
    
    self.titleLabel.preferredMaxLayoutWidth = self.frame.size.width - (2 * self.contentPadding);
    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(self.frame.size.width - (2 * self.contentPadding), CGFLOAT_MAX)];
    self.titleLabel.frame = (CGRect){{self.contentPadding, self.contentPadding}, size};
    
    self.assigneeProfileImageView.frame = CGRectMake(self.contentPadding, self.titleLabel.bottom + 12, profileSideLen, profileSideLen);
    
    [self.assigneeTextLabel sizeToFit];
    self.assigneeTextLabel.frame = (CGRect){{self.assigneeProfileImageView.right + 5, self.assigneeProfileImageView.top}, self.assigneeTextLabel.frame.size};
    
    [self.assigneeDisplayNameLabel sizeToFit];
    self.assigneeDisplayNameLabel.frame = (CGRect){{self.assigneeProfileImageView.right + 5, self.assigneeTextLabel.bottom + 3}, self.assigneeDisplayNameLabel.frame.size};
    
    CGRect newAssignFrame = CGRectZero;
    newAssignFrame.origin = self.assigneeProfileImageView.frame.origin;
    newAssignFrame.size.width = MAX(self.assigneeTextLabel.right, self.assigneeDisplayNameLabel.right) - self.assigneeProfileImageView.left;
    newAssignFrame.size.height = self.assigneeDisplayNameLabel.bottom - self.assigneeTextLabel.top;
    self.assignButton.frame = newAssignFrame;
}

- (CGSize)sizeThatFits:(CGSize)size {
    self.frame = (CGRect){CGPointZero, size};
    [self layoutSubviews];
    
    return CGSizeMake(size.width, self.assigneeDisplayNameLabel.bottom + self.contentPadding);
}

#pragma mark - Modeling
- (void)applyIssueModel:(OZLModelIssue *)issue {
    self.titleLabel.attributedText = [self applyTitleAttributesToText:issue.subject];
    
    if (issue.assignedTo) {
        self.assigneeDisplayNameLabel.font = [UIFont systemFontOfSize:assigneeTextSize];
        self.assigneeDisplayNameLabel.text = issue.assignedTo.name;
        self.assigneeDisplayNameLabel.textColor = [UIColor blackColor];
        
    } else {
        self.assigneeDisplayNameLabel.font = [UIFont italicSystemFontOfSize:assigneeTextSize];
        self.assigneeDisplayNameLabel.text = @"Tap to assign";
        self.assigneeDisplayNameLabel.textColor = [UIColor grayColor];
    }
}

- (NSAttributedString *)applyTitleAttributesToText:(NSString *)text {
    NSAssert(text, @"Tried to apply title attributes to nil text");
    
    if (!text) {
        return nil;
    }
    
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.lineHeightMultiple = 1.15;
    
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:text attributes:@{ NSParagraphStyleAttributeName: para} ];
    
    return attr;
}

@end
