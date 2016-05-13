//
//  OZLTableViewCell.m
//  Facets
//
//  Created by Justin Hill on 11/6/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLTableViewCell.h"

@implementation OZLTableViewCell

+ (CGFloat)heightForWidth:(CGFloat)width model:(NSObject  * _Nonnull)model layoutMargins:(UIEdgeInsets)layoutMargins {
    NSAssert(NO, @"heightForWidth:model:layoutMargins: must be overridden in a subclass.");
    return 0;
}

@end
