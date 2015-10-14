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

@interface OZLMainTabControllerViewController ()

@property OZLProjectListViewController *projectListVC;
@property OZLAccountViewController *settingsVC;

@end

@implementation OZLMainTabControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.projectListVC = [[OZLProjectListViewController alloc] initWithNibName:@"OZLProjectListViewController" bundle:nil];
    self.settingsVC = [[OZLAccountViewController alloc] initWithNibName:@"OZLAccountViewController" bundle:nil];
    
    UINavigationController *projectNav = [[UINavigationController alloc] initWithRootViewController:self.projectListVC];
    projectNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Projects" image:nil tag:0];
    
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:self.settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:nil tag:0];
    
    self.viewControllers = @[ projectNav, settingsNav ];
    
    if ([OZLSingleton sharedInstance].redmineUserName &&
        [OZLSingleton sharedInstance].redminePassword &&
        [OZLSingleton sharedInstance].redmineHomeURL) {
        
        self.selectedViewController = self.projectListVC.navigationController;
    } else {
        
        self.selectedViewController = self.settingsVC.navigationController;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
