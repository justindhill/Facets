//
//  OZLSingleton.m
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/15/13.

#import "OZLSingleton.h"
#import "OZLConstants.h"
#import "OZLNetwork.h"

@interface OZLSingleton ()

@property (strong) OZLServerSync *serverSync;
@property (strong) NSURLSession *urlSession;

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
            USER_DEFAULTS_REDMINE_HOME_URL:   @"https://redmine.franklychat.com",
            USER_DEFAULTS_REDMINE_USER_KEY:   @"",
            USER_DEFAULTS_LAST_PROJECT_ID:    @(NSNotFound),
            USER_DEFAULTS_REDMINE_USER_NAME:  @"",
            USER_DEFAULTS_REDMINE_PASSWORD:   @"",
            USER_DEFAULTS_ISSUE_LIST_FILTER:  @0,
            USER_DEFAULTS_ISSUE_LIST_SORT:    @0,
            USER_DEFAULTS_ISSUE_LIST_ASCEND:  @0
        };
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:dic];
        
        [OZLNetwork sharedInstance].baseURL = [NSURL URLWithString:self.redmineHomeURL];
        [self updateAuthHeader];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (BOOL)isUserLoggedIn {
    return (self.redmineUserName.length > 0);
}

#pragma mark - Accessors
- (NSString *)redmineHomeURL {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [userdefaults objectForKey:USER_DEFAULTS_REDMINE_HOME_URL];
}

- (void)setRedmineHomeURL:(NSString *)redmineHomeURL {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:redmineHomeURL forKey:USER_DEFAULTS_REDMINE_HOME_URL];
    [userdefaults synchronize];
    
    NSURL *url = [NSURL URLWithString:redmineHomeURL];
    [OZLNetwork sharedInstance].baseURL = url;
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
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.redmineUserName
                                                             password:self.redminePassword
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    NSURLComponents *components = [NSURLComponents componentsWithString:self.redmineHomeURL];
    NSInteger port;
    if (components.port) {
        port = [components.port integerValue];
    } else if ([components.scheme isEqualToString:@"https"]) {
        port = 443;
    } else {
        port = 80;
    }
    
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc]
                                             initWithHost:components.host
                                             port:port
                                             protocol:components.scheme
                                             realm:@"Redmine API"
                                             authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
    
    
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential
                                                        forProtectionSpace:protectionSpace];
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
        [[OZLNetwork sharedInstance] authenticateCredentialsWithURL:[NSURL URLWithString:self.redmineHomeURL] username:self.redmineUserName password:self.redminePassword completion:^(NSError *error) {
            if (!error) {
                 [self.serverSync startSyncCompletion:nil];
            }
        }];
    }
}

@end
