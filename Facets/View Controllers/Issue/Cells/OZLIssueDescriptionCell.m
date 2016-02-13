//
//  OZLIssueDescriptionCell.m
//  Facets
//
//  Created by Justin Hill on 11/6/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLIssueDescriptionCell.h"

@interface OZLIssueDescriptionCell ()

@property (strong) UILabel *descriptionPreviewLabel;

@property BOOL isFirstLayout;

@end

@implementation OZLIssueDescriptionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.descriptionPreviewLabel = [[UILabel alloc] init];
        self.descriptionPreviewLabel.textColor = [UIColor darkGrayColor];
        self.descriptionPreviewLabel.font = [UIFont systemFontOfSize:14];
        self.descriptionPreviewLabel.numberOfLines = 3;
        
        self.isFirstLayout = YES;
    }
    
    return self;
}

- (void)setDescriptionPreviewString:(NSString *)descriptionPreviewString {
    _descriptionPreviewString = descriptionPreviewString;
    
    self.descriptionPreviewLabel.text = [self transformStringForDisplay:descriptionPreviewString];
}

- (void)layoutSubviews {
    if (self.isFirstLayout) {
        [self.contentView addSubview:self.descriptionPreviewLabel];
    }
    
    if (self.descriptionPreviewLabel.text) {
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
        para.lineHeightMultiple = 1.2;
        para.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:self.descriptionPreviewLabel.text
                                                                   attributes:@{ NSParagraphStyleAttributeName: para }];
        
        self.descriptionPreviewLabel.attributedText = attr;
    }
    
    CGSize descSize = [self.descriptionPreviewLabel sizeThatFits:CGSizeMake(self.frame.size.width - (self.contentPadding * 2), CGFLOAT_MAX)];
    
    self.descriptionPreviewLabel.frame = (CGRect){{self.contentPadding, 6.}, descSize};
    
    self.isFirstLayout = NO;
}

+ (CGFloat)heightWithWidth:(CGFloat)width description:(NSString *)description contentPadding:(CGFloat)padding {
    static OZLIssueDescriptionCell * sizingCell;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    });
    
    sizingCell.bounds = CGRectMake(0, 0, width, 0);
    sizingCell.contentPadding = padding;
    sizingCell.descriptionPreviewLabel.text = description;
    [sizingCell layoutSubviews];
    
    return sizingCell.descriptionPreviewLabel.bottom + sizingCell.contentPadding;
}

- (NSString *)transformStringForDisplay:(NSString *)string {
    
    return [[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
}

@end
