//
//  OZLTableViewCell.m
//  Facets
//
//  Created by Justin Hill on 11/6/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLTableViewCell.h"

@implementation OZLTableViewCell

+ (UILabel *)labelConfiguredForTitle {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor lightGrayColor];
    
    return titleLabel;
}

@end
