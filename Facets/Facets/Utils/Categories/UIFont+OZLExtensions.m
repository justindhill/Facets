//
//  UIFont+OZLExtensions.m
//  Facets
//
//  Created by Justin Hill on 11/5/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "UIFont+OZLExtensions.h"

@implementation UIFont (OZLExtensions)

+ (UIFont *)OZLMediumSystemFontOfSize:(CGFloat)size {
    if ([self respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        return [self systemFontOfSize:size weight:UIFontWeightSemibold];
    } else {
        return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
    }
}

@end
