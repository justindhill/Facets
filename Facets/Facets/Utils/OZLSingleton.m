//
//  OZLSingleton.m
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/15/13.

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

#import "OZLSingleton.h"
#import "OZLConstants.h"

@interface OZLSingleton ()

@property (strong) OZLServerSync *serverSync;
@property (nonatomic, strong) AFHTTPClient *httpClient;

@end

@implementation OZLSingleton

NSString * const USER_DEFAULTS_REDMINE_HOME_URL = @"USER_DEFAULTS_REDMINE_HOME_URL";
NSString * const USER_DEFAULTS_REDMINE_USER_KEY = @"USER_DEFAULTS_REDMINE_USER_KEY";
NSString * const USER_DEFAULTS_LAST_PROJECT_ID = @"USER_DEFAULTS_LAST_PROJECT_ID";
NSString * const USER_DEFAULTS_REDMINE_USER_NAME = @"USER_DEFAULTS_REDMINE_USER_NAME";
NSString * const USER_DEFAULTS_REDMINE_PASSWORD = @"USER_DEFAULTS_REDMINE_PASSWORD";

//issue list option
NSString * const USER_DEFAULTS_ISSUE_LIST_ASCEND = @"USER_DEFAULTS_ISSUE_LIST_ASCEND";// ascend or descend
NSString * const USER_DEFAULTS_ISSUE_LIST_FILTER = @"USER_DEFAULTS_ISSUE_LIST_FILTER";
NSString * const USER_DEFAULTS_ISSUE_LIST_SORT = @"USER_DEFAULTS_ISSUE_LIST_SORT";

+ (OZLSingleton *)sharedInstance {
    static OZLSingleton * _sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OZLSingleton alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.serverSync = [[OZLServerSync alloc] init];
        
        NSDictionary *dic = @{
            USER_DEFAULTS_REDMINE_HOME_URL:   @"http://demo.redmine.org",
            USER_DEFAULTS_REDMINE_USER_KEY:   @"",
            USER_DEFAULTS_LAST_PROJECT_ID:    @(NSNotFound),
            USER_DEFAULTS_REDMINE_USER_NAME:  @"",
            USER_DEFAULTS_REDMINE_PASSWORD:   @"",
            USER_DEFAULTS_ISSUE_LIST_FILTER:  @0,
            USER_DEFAULTS_ISSUE_LIST_SORT:    @0,
            USER_DEFAULTS_ISSUE_LIST_ASCEND:  @0
        };
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:dic];
        
        if (self.redmineHomeURL) {
            self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:self.redmineHomeURL]];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (BOOL)isUserLoggedIn {
    return (self.redmineUserName.length > 0);
}

#pragma mark - Accessors
- (void)setHttpClient:(AFHTTPClient *)httpClient {
    _httpClient = httpClient;
    
    if (httpClient) {
        [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
        [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self updateAuthHeader];
    }
}

- (NSString *)redmineHomeURL {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [userdefaults objectForKey:USER_DEFAULTS_REDMINE_HOME_URL];
}

- (void)setRedmineHomeURL:(NSString *)redmineHomeURL {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:redmineHomeURL forKey:USER_DEFAULTS_REDMINE_HOME_URL];
    [userdefaults synchronize];
    
    NSURL *url = [NSURL URLWithString:redmineHomeURL];
    
    if (![url isEqual:self.httpClient.baseURL]) {
        self.httpClient = [AFHTTPClient clientWithBaseURL:url];
    }
}

- (NSString *)redmineUserKey {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [userdefaults objectForKey:USER_DEFAULTS_REDMINE_USER_KEY];
}

- (void)setRedmineUserKey:(NSString *)redmineUserKey {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:redmineUserKey forKey:USER_DEFAULTS_REDMINE_USER_KEY];
    [userdefaults synchronize];    
}

- (NSInteger)currentProjectID {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [userdefaults integerForKey:USER_DEFAULTS_LAST_PROJECT_ID];
}

- (void)setCurrentProjectID:(NSInteger)projectid {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setInteger:projectid forKey:USER_DEFAULTS_LAST_PROJECT_ID];
    [userdefaults synchronize];
}

- (NSString *)redmineUserName {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [userdefaults objectForKey:USER_DEFAULTS_REDMINE_USER_NAME];
}

- (void)setRedmineUserName:(NSString *)redmineUserName {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:redmineUserName forKey:USER_DEFAULTS_REDMINE_USER_NAME];
    [userdefaults synchronize];
    [self updateAuthHeader];
}

- (NSString *)redminePassword {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [userdefaults objectForKey:USER_DEFAULTS_REDMINE_PASSWORD];
}

- (void)setRedminePassword:(NSString *)redminePassword {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:redminePassword forKey:USER_DEFAULTS_REDMINE_PASSWORD];
    [userdefaults synchronize];
    [self updateAuthHeader];
}

- (NSInteger)issueListFilterType {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [[userdefaults objectForKey:USER_DEFAULTS_ISSUE_LIST_FILTER] integerValue];
}

- (void)setIssueListFilterType:(NSInteger)issueListFilterType {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:@(issueListFilterType) forKey:USER_DEFAULTS_ISSUE_LIST_FILTER];
    [userdefaults synchronize];
}

- (NSInteger)issueListSortAscending {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [[userdefaults objectForKey:USER_DEFAULTS_ISSUE_LIST_ASCEND] integerValue];
}

- (void)setIssueListSortAscending:(NSInteger)issueListSortAscending {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:@(issueListSortAscending) forKey:USER_DEFAULTS_ISSUE_LIST_ASCEND];
    [userdefaults synchronize];
}

- (NSInteger)issueListSortType {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [[userdefaults objectForKey:USER_DEFAULTS_ISSUE_LIST_SORT] intValue];
}

- (void)setIssueListSortType:(NSInteger)issueListSortType {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:@(issueListSortType) forKey:USER_DEFAULTS_ISSUE_LIST_SORT];
    [userdefaults synchronize];
}

- (void)updateAuthHeader {
    [self.httpClient setAuthorizationHeaderWithUsername:self.redmineUserName password:self.redminePassword];
}

#pragma mark -
#pragma mark data retrival
- (OZLModelTracker *)trackerWithId:(NSInteger)index {
    
    for (OZLModelTracker *tracker in _trackerList) {
        if (tracker.index == index) {
            return tracker;
        }
    }
    
    return nil;
}

- (OZLModelIssuePriority *)issuePriorityWithId:(NSInteger)index {
    
    for (OZLModelIssuePriority *priority in _priorityList) {
        if (priority.index == index) {
            return priority;
        }
    }
    
    return nil;
}

- (OZLModelIssueStatus *)issueStatusWithId:(NSInteger)index {
    
    for (OZLModelIssueStatus *status in _statusList) {
        if (status.index == index) {
            return status;
        }
    }
    
    return nil;
}

- (OZLModelUser *)userWithId:(NSInteger)index {
    
    for (OZLModelUser  *user in _userList) {
        if (user.index == index) {
            return user;
        }
    }
    
    return nil;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.isUserLoggedIn) {
        [self.serverSync startSyncCompletion:nil];
    }
}

@end
