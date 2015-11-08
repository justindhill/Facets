//
//  OZLIssueDescriptionCell.h
//  Facets
//
//  Created by Justin Hill on 11/6/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLTableViewCell.h"

@interface OZLIssueDescriptionCell : OZLTableViewCell

@property (nonatomic, strong) NSString *descriptionPreviewString;
@property (readonly, strong) UIButton *showMoreButton;

+ (CGFloat)heightForWidth:(CGFloat)width description:(NSString *)description contentPadding:(CGFloat)padding;

@end
