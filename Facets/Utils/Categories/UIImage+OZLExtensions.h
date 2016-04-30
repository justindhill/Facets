//
//  UIImage+OZLExtensions.h
//  Facets
//
//  Created by Justin Hill on 12/6/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import UIKit;

@interface UIImage (OZLExtensions)

+ (UIImage *)ozl_templateImageNamed:(NSString *)name;
+ (UIImage *)ozl_imageNamed:(NSString *)name maskedWithColor:(UIColor *)color;

@end
