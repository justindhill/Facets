//
//  OZLLoadingView.m
//  Facets
//
//  Created by Justin Hill on 11/10/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLLoadingView.h"

@interface OZLLoadingView ()

@property (strong) DRPLoadingSpinner *loadingSpinner;
@property (strong) UILabel *errorMessageLabel;

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
    self.backgroundColor = [UIColor whiteColor];

    self.loadingSpinner = [[DRPLoadingSpinner alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    self.loadingSpinner.colorSequence = @[ [UIColor lightGrayColor] ];
    self.loadingSpinner.minimumArcLength = (M_PI / 3.);
    self.loadingSpinner.lineWidth = 1.;
    self.loadingSpinner.drawCycleDuration = .75;
    self.loadingSpinner.rotationCycleDuration = 1.5;

    self.errorMessageLabel = [[UILabel alloc] init];
    self.errorMessageLabel.textColor = [UIColor lightGrayColor];
    self.errorMessageLabel.font = [UIFont systemFontOfSize:16.0];
    self.errorMessageLabel.numberOfLines = 0;
}

- (void)layoutSubviews {
    if (!self.loadingSpinner.superview) {
        [self addSubview:self.loadingSpinner];
        [self addSubview:self.errorMessageLabel];
    }
    
    CGFloat xOffset = floorf((self.frame.size.width - self.loadingSpinner.frame.size.width) / 2.);
    CGFloat yOffset = floorf((self.frame.size.height - self.loadingSpinner.frame.size.height) / 2.);
    
    self.loadingSpinner.frame = (CGRect){{xOffset, yOffset}, self.loadingSpinner.frame.size};

    if (self.errorMessageLabel.text.length > 0) {
        CGFloat usableWidth = self.frame.size.width - 80.0;
        self.errorMessageLabel.frame = CGRectMake(0, 0, usableWidth, 0);
        [self.errorMessageLabel sizeToFit];

        CGFloat errorX = ceilf((self.frame.size.width - self.errorMessageLabel.frame.size.width) / 2.0);
        CGFloat errorY = ceilf((self.frame.size.height - self.errorMessageLabel.frame.size.height) / 2.0);
        self.errorMessageLabel.frame = (CGRect){{errorX, errorY}, self.errorMessageLabel.frame.size};
    }
}

- (void)startLoading {
    self.loadingSpinner.hidden = NO;
    self.errorMessageLabel.hidden = YES;

    [self.loadingSpinner startAnimating];
    [self setNeedsLayout];
}

- (void)endLoading {
    [self endLoadingWithErrorMessage:nil];
}

- (void)endLoadingWithErrorMessage:(NSString *)errorMessage {
    self.loadingSpinner.hidden = YES;
    self.errorMessageLabel.hidden = (errorMessage.length == 0);
    self.errorMessageLabel.text = errorMessage;

    [self.loadingSpinner stopAnimating];
    [self setNeedsLayout];
}

@end
