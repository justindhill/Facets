//
//  UIImage+OZLExtensions.m
//  Facets
//
//  Created by Justin Hill on 12/6/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "UIImage+OZLExtensions.h"

@implementation UIImage (OZLExtensions)

+ (UIImage *)ozl_templateImageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
