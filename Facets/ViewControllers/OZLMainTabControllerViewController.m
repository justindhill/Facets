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

@property OZLSplitViewController *projectSplitView;

@end

@implementation OZLMainTabControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tabBar.translucent = NO;
    self.tabBar.barTintColor = [UIColor whiteColor];
    
    self.projectIssuesVC = [[OZLIssueListViewController alloc] initWithNibName:@"OZLIssueListViewController" bundle:nil];
    self.projectIssuesVC.viewModel = [[OZLProjectIssueListViewModel alloc] init];
    
    self.queryListVC = [[OZLQueryListViewController alloc] initWithNibName:@"OZLQueryListViewController" bundle:nil];
    
    self.settingsVC = [[OZLAccountViewController alloc] initWithNibName:@"OZLAccountViewController" bundle:nil];
    self.settingsVC.delegate = self;
    
    OZLSplitViewController *projectSplitView = [[OZLSplitViewController alloc] init];
    self.projectSplitView = projectSplitView;
    projectSplitView.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    projectSplitView.extendedLayoutIncludesOpaqueBars = YES;
    projectSplitView.masterNavigationController.extendedLayoutIncludesOpaqueBars = YES;
    projectSplitView.detailNavigationController.extendedLayoutIncludesOpaqueBars = YES;
    projectSplitView.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Issues" image:nil tag:0];
    
    projectSplitView.masterNavigationController.navigationBar.translucent = NO;
    projectSplitView.masterNavigationController.navigationBar.barTintColor = [UIColor whiteColor];
    projectSplitView.detailNavigationController.navigationBar.translucent = NO;
    projectSplitView.detailNavigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    projectSplitView.masterNavigationController.viewControllers = @[ self.projectIssuesVC ];
    
    UINavigationController *queryListNav = [[UINavigationController alloc] initWithRootViewController:self.queryListVC];
    queryListNav.navigationBar.translucent = NO;
    queryListNav.navigationBar.barTintColor = [UIColor whiteColor];
    queryListNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Queries" image:nil tag:0];
    
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:self.settingsVC];
    settingsNav.navigationBar.translucent = NO;
    queryListNav.navigationBar.barTintColor = [UIColor whiteColor];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:nil tag:0];
    
    self.viewControllers = @[ projectSplitView, queryListNav, settingsNav ];
    
    if ([OZLSingleton sharedInstance].isUserLoggedIn && [OZLSingleton sharedInstance].currentProjectID != NSNotFound) {
        self.projectIssuesVC.viewModel.projectId = [OZLSingleton sharedInstance].currentProjectID;
        self.selectedViewController = self.projectSplitView;
    } else {
        self.selectedViewController = self.settingsVC.navigationController;
        self.settingsVC.isFirstLogin = YES;
    }
}

#pragma mark - Account view controller delegate
- (void)accountViewControllerDidSuccessfullyAuthenticate:(OZLAccountViewController *)account shouldTransitionToIssues:(BOOL)shouldTransition {
    if (shouldTransition) {
        [CATransaction begin];
        
        CATransition *transition = [[CATransition alloc] init];
        transition.duration = .3;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.view.layer addAnimation:transition forKey:nil];
        
        [self setSelectedIndex:0];
        
        [CATransaction commit];
    }
}

@end
