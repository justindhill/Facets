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

@interface OZLAccountViewController (){
    float _sideviewOffset;
}

@end

@implementation OZLAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _redmineHomeURL.text = [[OZLSingleton sharedInstance] redmineHomeURL];
    _redmineUserKey.text = [[OZLSingleton sharedInstance] redmineUserKey];
    _username.text = [[OZLSingleton sharedInstance] redmineUserName];
    _password.text = [[OZLSingleton sharedInstance] redminePassword];

    UITapGestureRecognizer* tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.view addGestureRecognizer:tapper];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[OZLSingleton sharedInstance] setRedmineUserKey:_redmineUserKey.text];
    [[OZLSingleton sharedInstance] setRedmineHomeURL:_redmineHomeURL.text];
    [[OZLSingleton sharedInstance] setRedmineUserName:_username.text];
    [[OZLSingleton sharedInstance] setRedminePassword:_password.text];
    [[OZLSingleton sharedInstance] setLastProjectID:-1];

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_REDMINE_ACCOUNT_CHANGED object:nil];
}

- (void)backgroundTapped {
    [self.view endEditing:YES];
}

@end
