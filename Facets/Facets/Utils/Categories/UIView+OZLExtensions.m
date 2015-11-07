//
//  UIView+OZLExtensions.m
//  Facets
//
//  Created by Justin Hill on 11/5/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "UIView+OZLExtensions.h"

@implementation UIView (OZLExtensions)

- (CGFloat)top {
    return self.frame.origin.y;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

@end
