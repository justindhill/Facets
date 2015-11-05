//
//  OZLMainTabControllerViewController.m
//  RedmineMobile
//
//  Created by Justin Hill on 10/14/15.
//  Copyright © 2015 Lee Zhijie. All rights reserved.
//

#import "OZLMainTabControllerViewController.h"
#import "OZLAccountViewController.h"
#import "OZLProjectListViewController.h"
#import "OZLIssueListViewController.h"
#import "OZLQueryListViewController.h"
#import "OZLProjectIssueListViewModel.h"

@interface OZLMainTabControllerViewController () <OZLAccountViewControllerDelegate>

@property OZLIssueListViewController *projectIssuesVC;
@property OZLAccountViewController *settingsVC;
@property OZLQueryListViewController *queryListVC;

@end

@implementation OZLMainTabControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.projectIssuesVC = [[OZLIssueListViewController alloc] initWithNibName:@"OZLIssueListViewController" bundle:nil];
    self.projectIssuesVC.viewModel = [[OZLProjectIssueListViewModel alloc] init];
    
    self.queryListVC = [[OZLQueryListViewController alloc] initWithNibName:@"OZLQueryListViewController" bundle:nil];
    
    self.settingsVC = [[OZLAccountViewController alloc] initWithNibName:@"OZLAccountViewController" bundle:nil];
    self.settingsVC.delegate = self;
    
    UINavigationController *projectNav = [[UINavigationController alloc] initWithRootViewController:self.projectIssuesVC];
    projectNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Issues" image:nil tag:0];
    
    UINavigationController *queryListNav = [[UINavigationController alloc] initWithRootViewController:self.queryListVC];
    queryListNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Queries" image:nil tag:0];
    
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:self.settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:nil tag:0];
    
    self.viewControllers = @[ projectNav, queryListNav, settingsNav ];
    
    if ([OZLSingleton sharedInstance].isUserLoggedIn && [OZLSingleton sharedInstance].currentProjectID != NSNotFound) {
        self.projectIssuesVC.viewModel.projectId = [OZLSingleton sharedInstance].currentProjectID;
        self.selectedViewController = self.projectIssuesVC.navigationController;
    } else {
        self.selectedViewController = self.settingsVC.navigationController;
        self.settingsVC.isFirstLogin = YES;
    }
}

#pragma mark - Account view controller delegate
- (void)accountViewControllerDidSuccessfullyAuthenticate:(OZLAccountViewController *)account shouldTransitionToIssues:(BOOL)shouldTransition {
    if (shouldTransition) {
        [CATransaction begin];
        [UIView transitionFromView:self.selectedViewController.view toView:self.projectIssuesVC.navigationController.view duration:.4 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            if (finished) {
                self.selectedViewController = self.projectIssuesVC.navigationController;
            }
        }];
        [CATransaction commit];
    }
}

@end
