//
//  OZLAccountViewController.m
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/14/13.

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2013 Zhijie Lee(onezeros.lee@gmail.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "OZLAccountViewController.h"
#import "OZLProjectListViewController.h"
#import "OZLSingleton.h"
#import "OZLConstants.h"
#import "OZLNetwork.h"
#import "OZLModelProject.h"

#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

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

    UITapGestureRecognizer* tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.view addGestureRecognizer:tapper];
}

- (void)saveButtonAction:(id)sender {
    
    __weak OZLAccountViewController *weakSelf = self;
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.animationType = MBProgressHUDAnimationZoom;
    
    NSURL *baseURL = [NSURL URLWithString:_redmineHomeURL.text];
    [[OZLNetwork sharedInstance] validateCredentialsWithURL:baseURL username:_username.text password:_password.text completion:^(NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Couldn't validate credentials" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            [weakSelf presentViewController:alert animated:YES completion:nil];
        } else {
            [[OZLSingleton sharedInstance] setRedmineUserKey:_redmineUserKey.text];
            [[OZLSingleton sharedInstance] setRedmineHomeURL:_redmineHomeURL.text];
            [[OZLSingleton sharedInstance] setRedmineUserName:_username.text];
            [[OZLSingleton sharedInstance] setRedminePassword:_password.text];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REDMINE_ACCOUNT_CHANGED object:nil];
            
            [[OZLSingleton sharedInstance].serverSync startSyncCompletion:^(NSError *error) {
                [weakSelf.delegate accountViewControllerDidSuccessfullyAuthenticate:weakSelf shouldTransitionToIssues:weakSelf.isFirstLogin];
                weakSelf.isFirstLogin = NO;
            }];
        }
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}

- (void)backgroundTapped {
    [self.view endEditing:YES];
}

@end
