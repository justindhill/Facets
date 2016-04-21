//
//  OZLAccountViewController.m
//  Facets
//
//  Created by Lee Zhijie on 7/14/13.

#import "OZLAccountViewController.h"
#import "OZLSingleton.h"
#import "OZLConstants.h"
#import "OZLNetwork.h"
#import "OZLModelProject.h"

@import MBProgressHUD;

@interface OZLAccountViewController ()

@end

@implementation OZLAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";

    _redmineHomeURL.text = [[OZLSingleton sharedInstance] redmineHomeURL];
    _redmineUserKey.text = [[OZLSingleton sharedInstance] redmineUserKey];
    _username.text = [[OZLSingleton sharedInstance] redmineUserName];
    _password.text = [[OZLSingleton sharedInstance] redminePassword];

    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.view addGestureRecognizer:tapper];
}

- (void)saveButtonAction:(id)sender {
    
    __weak OZLAccountViewController *weakSelf = self;
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.animationType = MBProgressHUDAnimationZoom;
    
    NSURL *baseURL = [NSURL URLWithString:_redmineHomeURL.text];
    [[OZLNetwork sharedInstance] authenticateCredentialsWithURL:baseURL username:_username.text password:_password.text completion:^(NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Couldn't validate credentials" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            [weakSelf presentViewController:alert animated:YES completion:nil];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        } else {
            [[OZLSingleton sharedInstance] setRedmineUserKey:_redmineUserKey.text];
            [[OZLSingleton sharedInstance] setRedmineHomeURL:_redmineHomeURL.text];
            [[OZLSingleton sharedInstance] setRedmineUserName:_username.text];
            [[OZLSingleton sharedInstance] setRedminePassword:_password.text];
            
            [weakSelf startSync];
        }
    }];
}

- (void)startSync {
    __weak OZLAccountViewController *weakSelf = self;
    
    [[OZLSingleton sharedInstance].serverSync startSyncCompletion:^(NSError *error) {
        [weakSelf.delegate accountViewControllerDidSuccessfullyAuthenticate:weakSelf shouldTransitionToIssues:weakSelf.isFirstLogin];
        weakSelf.isFirstLogin = NO;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}

- (void)backgroundTapped {
    [self.view endEditing:YES];
}

@end
