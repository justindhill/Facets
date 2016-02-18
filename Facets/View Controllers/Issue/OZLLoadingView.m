//
//  OZLLoadingView.m
//  Facets
//
//  Created by Justin Hill on 11/10/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLLoadingView.h"

@interface OZLLoadingView ()

@property BOOL isFirstLayout;

@end

@implementation OZLLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.isFirstLayout = YES;
    self.loadingSpinner = [[DRPLoadingSpinner alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    self.loadingSpinner.colorSequence = @[ [UIColor lightGrayColor] ];
    self.loadingSpinner.minimumArcLength = (M_PI / 3.);
    self.loadingSpinner.lineWidth = 1.;
    self.loadingSpinner.drawCycleDuration = .75;
    self.loadingSpinner.rotationCycleDuration = 1.5;
}

- (void)layoutSubviews {
    if (self.isFirstLayout) {
        [self addSubview:self.loadingSpinner];
    }
    
    CGFloat xOffset = floorf((self.frame.size.width - self.loadingSpinner.frame.size.width) / 2.);
    CGFloat yOffset = floorf((self.frame.size.height - self.loadingSpinner.frame.size.height) / 2.);
    
    self.loadingSpinner.frame = (CGRect){{xOffset, yOffset}, self.loadingSpinner.frame.size};
    
    self.isFirstLayout = NO;
}

@end
