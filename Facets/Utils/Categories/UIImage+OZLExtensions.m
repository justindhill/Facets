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

+ (UIImage *)ozl_imageNamed:(NSString *)name maskedWithColor:(UIColor *)color {
    UIImage *image = [self imageNamed:name];

    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [color setFill];

    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));

    UIImage *coloredImg = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    UIGraphicsEndImageContext();

    return coloredImg;
}

@end
