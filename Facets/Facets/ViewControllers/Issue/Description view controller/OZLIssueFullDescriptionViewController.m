//
//  OZLIssueFullDescriptionViewController.m
//  Facets
//
//  Created by Justin Hill on 11/10/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLIssueFullDescriptionViewController.h"
#import <SafariServices/SafariServices.h>

@interface OZLIssueFullDescriptionViewController () <TTTAttributedLabelDelegate>

@property BOOL isFirstAppearance;

@end

@implementation OZLIssueFullDescriptionViewController

#pragma mark - Life cycle
- (void)loadView {
    self.view = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.descriptionLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        self.descriptionLabel.textColor = [UIColor darkGrayColor];
        self.descriptionLabel.font = [UIFont systemFontOfSize:14.];
        self.descriptionLabel.numberOfLines = 0;
        self.descriptionLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        self.descriptionLabel.delegate = self;
        
        self.isFirstAppearance = YES;
        self.title = @"Description";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isFirstAppearance) {
        [self.view addSubview:self.descriptionLabel];
    }
    
    CGFloat width = self.view.frame.size.width - (2 * self.contentPadding);
    self.descriptionLabel.frame = CGRectMake(self.contentPadding, self.contentPadding, width, 0);
    [self.descriptionLabel sizeToFit];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                             self.descriptionLabel.bottom + self.contentPadding);
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent) {
        self.descriptionLabel.linkAttributes = @{ (NSString *)kCTForegroundColorAttributeName: parent.view.tintColor };
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.isFirstAppearance = NO;
}

#pragma mark - Accessors
- (UIScrollView *)scrollView {
    return (UIScrollView *)self.view;
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (NSClassFromString(@"SFSafariViewController") != Nil) {
        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:safari animated:YES completion:nil];
        
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}


@end
