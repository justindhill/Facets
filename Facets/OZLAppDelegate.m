//
//  OZLAppDelegate.m
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/14/13.

#import "OZLAppDelegate.h"
#import "OZLIssueListViewController.h"
#import "OZLSingleton.h"
#import "OZLModelProject.h"
#import "OZLAccountViewController.h"
#import "OZLMainTabControllerViewController.h"
#import "OZLURLProtocol.h"
#import "OZLNetwork.h"

#import <HockeySDK/HockeySDK.h>

@implementation OZLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#ifndef DEBUG
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"8d240e4921f15253d040d9347ad7d9ac"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[[BITHockeyManager sharedHockeyManager] authenticator] authenticateInstallation];
#endif // DEBUG
    
    [OZLNetwork sharedInstance];
    [OZLSingleton sharedInstance];
    
    [NSURLProtocol registerClass:[OZLURLProtocol class]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = [UIColor facetsBrandColor];
    self.window.backgroundColor = [UIColor whiteColor];

    OZLMainTabControllerViewController *mainVC = [[OZLMainTabControllerViewController alloc] init];
    self.window.rootViewController = mainVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
