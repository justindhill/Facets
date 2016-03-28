//
//  OZLSingleton.m
//  Facets
//
//  Created by Lee Zhijie on 7/15/13.

#import "OZLSingleton.h"
#import "OZLConstants.h"
#import "OZLNetwork.h"

@interface OZLSingleton ()

@property (strong) OZLServerSync *serverSync;

@end

@implementation OZLSingleton

NSString * const USER_DEFAULTS_REDMINE_HOME_URL = @"USER_DEFAULTS_REDMINE_HOME_URL";
NSString * const USER_DEFAULTS_REDMINE_USER_KEY = @"USER_DEFAULTS_REDMINE_USER_KEY";
NSString * const USER_DEFAULTS_LAST_PROJECT_ID = @"USER_DEFAULTS_LAST_PROJECT_ID";
NSString * const USER_DEFAULTS_REDMINE_USER_NAME = @"USER_DEFAULTS_REDMINE_USER_NAME";
NSString * const USER_DEFAULTS_REDMINE_PASSWORD = @"USER_DEFAULTS_REDMINE_PASSWORD";
NSString * const USER_DEFAULTS_REDMINE_COOKIE = @"USER_DEFAULTS_REDMINE_COOKIE";

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
            USER_DEFAULTS_REDMINE_PASSWORD:   @""
        };
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:dic];
        
        [OZLNetwork sharedInstance].baseURL = [NSURL URLWithString:self.redmineHomeURL];
        [self updateAuthHeader];
        
        if (self.isUserLoggedIn) {
            [[OZLNetwork sharedInstance] updateSessionCookieWithHost:self.redmineHomeURL
                                                        cookieHeader:self.redmineCookie];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (BOOL)isUserLoggedIn {
    return (self.redmineUserName.length > 0 && self.redminePassword.length > 0 && self.redmineCookie.length > 0);
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

- (NSString *)redmineCookie {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    return [userdefaults objectForKey:USER_DEFAULTS_REDMINE_COOKIE];
}

- (void)setRedmineCookie:(NSString *)redmineCookie {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:redmineCookie forKey:USER_DEFAULTS_REDMINE_COOKIE];
    [userdefaults synchronize];
    [self updateAuthHeader];
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

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.isUserLoggedIn) {
        [self.serverSync startSyncCompletion:nil];
    }
}

@end
