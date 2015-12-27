//
//  OZLTabTestView.m
//  Facets
//
//  Created by Justin Hill on 11/7/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLTabTestView.h"

@implementation OZLTabTestView

@synthesize heightChangeListener;

- (CGFloat)intrinsicHeightWithWidth:(CGFloat)width {
    return self.heightToReport;
}

@end
