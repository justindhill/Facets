//
//  OZLMainTabControllerViewController.m
//  RedmineMobile
//
//  Created by Justin Hill on 10/14/15.
//  Copyright © 2015 Lee Zhijie. All rights reserved.
//

#import "OZLMainTabControllerViewController.h"
#import "OZLAccountViewController.h"
#import "OZLIssueListViewController.h"
#import "OZLQueryListViewController.h"
#import "OZLProjectIssueListViewModel.h"

@interface OZLMainTabControllerViewController () <OZLAccountViewControllerDelegate>

@property OZLIssueListViewController *projectIssuesVC;
@property OZLAccountViewController *settingsVC;
@property OZLQueryListViewController *queryListVC;

@property OZLSplitViewController *projectSplitView;
@property OZLSplitViewController *queryListSplitView;

@end

@implementation OZLMainTabControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tabBar.translucent = NO;
    self.tabBar.barTintColor = [UIColor whiteColor];
    
    self.projectIssuesVC = [[OZLIssueListViewController alloc] initWithNibName:@"OZLIssueListViewController" bundle:nil];
    self.projectIssuesVC.viewModel = [[OZLProjectIssueListViewModel alloc] init];
    self.projectIssuesVC.view.tag = OZLSplitViewController.PrimaryPaneMember;
    
    self.queryListVC = [[OZLQueryListViewController alloc] initWithNibName:@"OZLQueryListViewController" bundle:nil];
    
    self.settingsVC = [[OZLAccountViewController alloc] initWithNibName:@"OZLAccountViewController" bundle:nil];
    self.settingsVC.delegate = self;
    
    self.projectSplitView = [self customizedSplitViewController];
    self.projectSplitView.masterNavigationController.viewControllers = @[ self.projectIssuesVC ];
    self.projectSplitView.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Issues" image:nil tag:0];
    
    self.queryListSplitView = [self customizedSplitViewController];
    self.queryListSplitView.masterNavigationController.viewControllers = @[ self.queryListVC ];
    self.queryListSplitView.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Queries" image:nil tag:0];
    
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:self.settingsVC];
    settingsNav.navigationBar.translucent = NO;
    settingsNav.navigationBar.barTintColor = [UIColor whiteColor];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:nil tag:0];
    
    self.viewControllers = @[ self.projectSplitView, self.queryListSplitView, settingsNav ];
    
    if ([OZLSingleton sharedInstance].isUserLoggedIn && [OZLSingleton sharedInstance].currentProjectID != NSNotFound) {
        self.projectIssuesVC.viewModel.projectId = [OZLSingleton sharedInstance].currentProjectID;
        self.selectedViewController = self.projectSplitView;
    } else {
        self.selectedViewController = self.settingsVC.navigationController;
        self.settingsVC.isFirstLogin = YES;
    }
}

- (OZLSplitViewController *)customizedSplitViewController {
    OZLSplitViewController *svc = [[OZLSplitViewController alloc] init];
    svc.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    svc.extendedLayoutIncludesOpaqueBars = YES;
    svc.masterNavigationController.extendedLayoutIncludesOpaqueBars = YES;
    svc.detailNavigationController.extendedLayoutIncludesOpaqueBars = YES;
    
    svc.masterNavigationController.navigationBar.translucent = NO;
    svc.masterNavigationController.navigationBar.barTintColor = [UIColor whiteColor];
    svc.detailNavigationController.navigationBar.translucent = NO;
    svc.detailNavigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    return svc;
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
