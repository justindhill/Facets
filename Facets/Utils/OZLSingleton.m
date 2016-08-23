//
//  OZLSingleton.m
//  Facets
//
//  Created by Lee Zhijie on 7/15/13.

#import "OZLSingleton.h"
#import "OZLConstants.h"
#import "OZLNetwork.h"
#import "Facets-Swift.h"

@import Jiramazing;

@interface OZLSingleton ()

@property (strong) OZLServerSync *serverSync;
@property (strong) OZLAttachmentManager *attachmentManager;

@end

@implementation OZLSingleton

NSString * const USER_DEFAULTS_BASE_URL = @"USER_DEFAULTS_BASE_URL";
NSString * const USER_DEFAULTS_LAST_PROJECT_ID = @"USER_DEFAULTS_LAST_PROJECT_ID";
NSString * const USER_DEFAULTS_USERNAME = @"USER_DEFAULTS_USERNAME";
NSString * const USER_DEFAULTS_PASSWORD = @"USER_DEFAULTS_PASSWORD";

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
        self.attachmentManager = [[OZLAttachmentManager alloc] initWithNetworkManager:[OZLNetwork sharedInstance]];
        
        NSDictionary *dic = @{
            USER_DEFAULTS_BASE_URL:   @"https://worldnow.atlassian.net",
            USER_DEFAULTS_LAST_PROJECT_ID:    @(NSNotFound),
            USER_DEFAULTS_USERNAME:  @"",
            USER_DEFAULTS_PASSWORD:   @""
        };
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:dic];

        [Jiramazing sharedInstance].baseUrl = [NSURL URLWithString:self.baseUrl];
        [Jiramazing sharedInstance].username = self.username;
        [Jiramazing sharedInstance].password = self.password;
    }
    
    return self;
}

- (BOOL)isUserLoggedIn {
    return (self.username.length > 0 && self.password.length > 0);
}

#pragma mark - Accessors
- (NSString *)baseUrl {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [userdefaults objectForKey:USER_DEFAULTS_BASE_URL];
}

- (void)setBaseUrl:(NSString *)baseUrl {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:baseUrl forKey:USER_DEFAULTS_BASE_URL];
    [userdefaults synchronize];
}

- (NSString *)currentProjectID {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [userdefaults stringForKey:USER_DEFAULTS_LAST_PROJECT_ID];
}

- (void)setCurrentProjectID:(NSInteger)projectid {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    [userdefaults setInteger:projectid forKey:USER_DEFAULTS_LAST_PROJECT_ID];
    [userdefaults synchronize];
}

- (NSString *)username {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [userdefaults objectForKey:USER_DEFAULTS_USERNAME];
}

- (void)setUsername:(NSString *)username {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:username forKey:USER_DEFAULTS_USERNAME];
    [userdefaults synchronize];
}

- (NSString *)password {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [userdefaults objectForKey:USER_DEFAULTS_PASSWORD];
}

- (void)setPassword:(NSString *)password {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:password forKey:USER_DEFAULTS_PASSWORD];
    [userdefaults synchronize];
}

@end
