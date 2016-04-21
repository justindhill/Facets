//
//  OZLNetwork.m
//  Facets
//
//  Created by Lee Zhijie on 7/14/13.

@import RaptureXML_Frankly;

#import "OZLNetwork.h"
#import "OZLSingleton.h"
#import "OZLURLProtocol.h"
#import "OZLRedmineHTMLParser.h"

#import "NSString+OZLURLEncoding.h"

NSString * const OZLNetworkErrorDomain = @"OZLNetworkErrorDomain";

@interface OZLNetwork () <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (strong) NSURLSession *urlSession;
@property NSOperationQueue *taskCallbackQueue;
@property (nonatomic, assign) NSInteger activeRequestCount;
@property NSObject *requestCountSyncToken;

@end

@implementation OZLNetwork

+ (instancetype)sharedInstance {
    static OZLNetwork  * _sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

+ (NSString *)encodedCredentialStringWithUsername:(NSString *)username password:(NSString *)password {
    NSString *credentials = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData *credentialData = [credentials dataUsingEncoding:NSUTF8StringEncoding];
    
    return [credentialData base64EncodedStringWithOptions:0];
}

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        
        self.taskCallbackQueue = [[NSOperationQueue alloc] init];
        self.urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.taskCallbackQueue];
        self.requestCountSyncToken = [[NSObject alloc] init];
    }
    
    return self;
}

- (void)setActiveRequestCount:(NSInteger)activeRequestCount {
    @synchronized(self.requestCountSyncToken) {
        _activeRequestCount = activeRequestCount;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = (activeRequestCount > 0);
    }
}

- (NSURL *)urlWithRelativePath:(NSString *)path {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.baseURL resolvingAgainstBaseURL:YES];
    components.path = path;
    
    return components.URL;
}

#pragma mark - Authorization
- (void)authenticateCredentialsWithURL:(NSURL *)url username:(NSString *)username password:(NSString *)password completion:(void(^)(NSError *error))completion {
    
    NSAssert(completion, @"validateCredentialsCompletion: expects a completion block");
    
    __weak OZLNetwork *weakSelf = self;
    
    [self fetchAuthValidationTokensWithBaseURL:url completion:^(NSString *authCookie, NSString *authToken, NSError *error) {
        NSLog(@"authCookie: %@\nauthToken: %@", authCookie, authToken);
        
        if (error) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
            
            return;
        }
    
        NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
        components.path = @"/login";
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
        request.HTTPShouldHandleCookies = NO;
        request.HTTPMethod = @"POST";
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:authCookie forHTTPHeaderField:@"Cookie"];
        
        NSString *encodedBackURL = [url.absoluteString URLEncodedString];
        NSString *encodedToken = [authToken URLEncodedString];
        NSString *formValueString = [NSString stringWithFormat:@"username=%@&password=%@&authenticity_token=%@&back_url=%@", [username URLEncodedString], [password URLEncodedString], encodedToken, encodedBackURL];
        request.HTTPBody = [formValueString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"request: %@", request);
        NSLog(@"form string: '%@'", formValueString);
        
        NSURLSessionDataTask *task = [weakSelf.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSError *reportError = error;
        
            // 302 Found indicates that the login was successful and we are being redirected. 200 OK indicates that the login
            // failed and we successfully loaded /login.
            if (httpResponse.statusCode != 302) {
                reportError = [NSError errorWithDomain:OZLNetworkErrorDomain code:OZLNetworkErrorInvalidCredentials userInfo:@{NSLocalizedDescriptionKey: @"Invalid username or password."}];
            
            }
            
            if (!reportError) {
                [OZLSingleton sharedInstance].redmineCookie = httpResponse.allHeaderFields[@"Set-Cookie"];
                [weakSelf updateSessionCookieWithHost:components.host cookieHeader:httpResponse.allHeaderFields[@"Set-Cookie"]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(reportError);
            });
        }];
        
        [task resume];
    }];
}

- (void)fetchAuthValidationTokensWithBaseURL:(NSURL *)baseURL completion:(void(^)(NSString *authCookie, NSString *authToken, NSError *error))completion {
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:baseURL resolvingAgainstBaseURL:YES];
    components.path = @"/login";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
    request.HTTPShouldHandleCookies = NO;
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        NSError *errorToReport = error;
        
        if (!errorToReport && (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300)) {
            NSString *errorString = [NSString stringWithFormat:@"Received an unacceptable status code from the server. (%ld)", (long)httpResponse.statusCode];
            errorToReport = [NSError errorWithDomain:OZLNetworkErrorDomain code:OZLNetworkErrorUnacceptableStatusCode userInfo:@{NSLocalizedDescriptionKey: errorString}];
        }
    
        if (errorToReport) {
            if (completion) {
                completion(nil, nil, error);
            }
            
            return;
        }
        
        NSString *authCookie = httpResponse.allHeaderFields[@"Set-Cookie"];
        
        __block NSString *authToken;
        
        RXMLElement *ele = [RXMLElement elementFromXMLData:data];
        RXMLElement *head = [ele child:@"head"];
        
        [head iterate:@"meta" usingBlock:^(RXMLElement *metaEle) {
            if ([[metaEle attribute:@"name"] isEqualToString:@"csrf-token"]) {
                authToken = [metaEle attribute:@"content"];
            }
        }];
        
        if (completion) {
            
            if (authCookie && authToken) {
                completion(authCookie, authToken, nil);
            } else {
                completion(nil, nil, [NSError errorWithDomain:OZLNetworkErrorDomain code:OZLNetworkErrorCouldntParseTokens userInfo:@{NSLocalizedDescriptionKey: @"Couldn't parse either the auth cookie or the auth token."}]);
            }
        }
    }];
    
    [task resume];
}

- (void)updateSessionCookieWithHost:(NSString *)host cookieHeader:(NSString *)cookieHeader {
    NSString *cookieName = @"_redmine_session";
    NSString *cookieString = [cookieHeader substringFromIndex:cookieName.length + 1];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{NSHTTPCookieName: cookieName,
                                                                NSHTTPCookieValue: cookieString,
                                                                NSHTTPCookiePath: @"/",
                                                                NSHTTPCookieDomain: host,
                                                                NSHTTPCookieExpires: [NSDate distantFuture]}];
    
    NSAssert(cookie, @"Couldn't create cookie");
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

#pragma mark-
#pragma mark project api
- (void)getProjectListWithParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion {

    [self GET:@"/projects.json" params:params completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError) {
            if (completion) {
                completion(nil, jsonError);
            }
            
            return;
        }
        
        NSArray *projectsDic = [responseObject objectForKey:@"projects"];
        NSMutableArray *projectModels = [NSMutableArray array];
        
        for (NSDictionary *p in projectsDic) {
            OZLModelProject *project = [[OZLModelProject alloc] initWithAttributeDictionary:p];
            [projectModels addObject:project];
        }
        
        if (completion) {
            completion(projectModels, nil);
        }
    }];
}

- (void)getCustomFieldsForProject:(NSInteger)project completion:(void (^)(NSArray<OZLModelCustomField *> *fields, NSError *error))completion {
    
    NSString *path = [NSString stringWithFormat:@"/projects/%ld/issues/new", (long)project];
    
    [self GET:path params:nil completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            
            return;
        }
        
        NSString *htmlString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSError *parseError;
        NSArray<OZLModelCustomField *> *fields = [OZLRedmineHTMLParser parseCustomFieldsHTMLString:htmlString error:&parseError];
        
        NSAssert(!parseError, @"There was an error parsing the custom fields from the HTML");
        
        if (parseError) {
            if (completion) {
                completion(nil, parseError);
            }
            
            return;
        }
        
        if (completion) {
            completion(fields, nil);
        }
    }];
}

- (void)getVersionsForProject:(NSInteger)project completion:(void (^)(NSArray<OZLModelVersion *> *versions, NSError *error))completion {
    
    NSString *path = [NSString stringWithFormat:@"/projects/%ld/versions.json", (long)project];
    
    [self GET:path params:nil completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            
            return;
        }
        
        NSError *parseError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&parseError];
        NSArray *versionDicts = responseObject[@"versions"];
        NSAssert(!parseError, @"There was an error deserializing the response.");
        
        if (parseError) {
            if (completion) {
                completion(nil, [NSError errorWithDomain:OZLNetworkErrorDomain code:OZLNetworkErrorInvalidResponse userInfo:@{NSLocalizedDescriptionKey: @"There was an error deserializing the response."}]);
            }
            
            return;
        }
        
        NSAssert([versionDicts isKindOfClass:[NSArray class]], @"The response was of an unexpected type.");
        if (![versionDicts isKindOfClass:[NSArray class]]) {
            if (completion) {
                completion(nil, [NSError errorWithDomain:OZLNetworkErrorDomain code:OZLNetworkErrorInvalidResponse userInfo:@{NSLocalizedDescriptionKey: @"The response was of an unexpected type."}]);
            }
            
            return;
        }
        
        NSMutableArray<OZLModelVersion *> *versions = [NSMutableArray array];
        
        for (NSDictionary *versionDict in versionDicts) {
            [versions addObject:[[OZLModelVersion alloc] initWithAttributeDictionary:versionDict]];
        }
        
        if (completion) {
            completion(versions, nil);
        }
    }];
}

- (void)getMembershipsForProject:(NSInteger)project offset:(NSInteger)offset limit:(NSInteger)limit completion:(void (^)(NSArray<OZLModelMembership *> *memberships, NSInteger totalCount, NSError *error))completion {
    
    NSString *path = [NSString stringWithFormat:@"/projects/%ld/memberships.json", (long)project];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (offset > 0) {
        params[@"offset"] = @(offset);
    }
    
    if (limit > 0) {
        params[@"limit"] = @(limit);
    }
    
    [self GET:path params:params completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, 0, error);
            }
            
            return;
        }
        
        NSError *parseError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&parseError];
        NSArray *membershipDicts = responseObject[@"memberships"];
        NSInteger totalCount = [responseObject[@"total_count"] integerValue];
        NSAssert(!parseError, @"There was an error deserializing the response.");
        
        if (parseError) {
            if (completion) {
                completion(nil, 0, [NSError errorWithDomain:OZLNetworkErrorDomain code:OZLNetworkErrorInvalidResponse userInfo:@{NSLocalizedDescriptionKey: @"There was an error deserializing the response."}]);
            }
            
            return;
        }
        
        NSAssert([membershipDicts isKindOfClass:[NSArray class]], @"The response was of an unexpected type.");
        if (![membershipDicts isKindOfClass:[NSArray class]]) {
            if (completion) {
                completion(nil, 0, [NSError errorWithDomain:OZLNetworkErrorDomain code:OZLNetworkErrorInvalidResponse userInfo:@{NSLocalizedDescriptionKey: @"The response was of an unexpected type."}]);
            }
            
            return;
        }
        
        NSMutableArray<OZLModelMembership *> *memberships = [NSMutableArray array];
        
        for (NSDictionary *membershipDict in membershipDicts) {
            [memberships addObject:[[OZLModelMembership alloc] initWithAttributeDictionary:membershipDict]];
        }
        
        if (completion) {
            completion(memberships, totalCount, nil);
        }
    }];
}

- (void)deleteProject:(NSInteger)projectid withParams:(NSDictionary *)params completion:(void (^)(BOOL success, NSError *error))completion {
    
    NSString *path = [NSString stringWithFormat:@"/projects/%ld.json", (long)projectid];
    
    [self DELETE:path completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error) {
            if (completion) {
                completion(NO, error);
            }
            
            return;
        }
        
        if (completion) {
            BOOL success = (response.statusCode == 201 && !error);
            
            completion(success, nil);
        }
    }];
}

#pragma mark -
#pragma mark issue api
- (void)getIssueListForProject:(NSInteger)projectid offset:(NSInteger)offset limit:(NSInteger)limit params:(NSDictionary *)params completion:(void (^)(NSArray *result, NSInteger totalCount, NSError *error))completion {
    
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    [paramsDic setObject:[NSNumber numberWithInteger:projectid] forKey:@"project_id"];
    
    if (offset > 0) {
        paramsDic[@"offset"] = @(offset);
    }
    
    if (limit > 0) {
        paramsDic[@"limit"] = @(limit);
    }
    
    [self GET:@"/issues.json" params:paramsDic completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error) {
            if (completion) {
                completion(nil, 0, error);
            }
            
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError) {
            if (completion) {
                completion(nil, 0, jsonError);
            }
            
            return;
        }

        if (completion) {

            NSMutableArray *issues = [[NSMutableArray alloc] init];

            NSInteger totalCount = [[responseObject objectForKey:@"total_count"] integerValue];
            NSArray *issuesDic = [responseObject objectForKey:@"issues"];
            
            for (NSDictionary *p in issuesDic) {
                [issues addObject:[[OZLModelIssue alloc] initWithDictionary:p]];
            }
            
            completion(issues, totalCount, nil);
        }
    }];
}

- (void)getIssueListForQueryId:(NSInteger)queryId projectId:(NSInteger)projectId offset:(NSInteger)offset limit:(NSInteger)limit params:(NSDictionary *)params completion:(void (^)(NSArray *result, NSInteger totalCount, NSError *error))completion {
    
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    paramsDic[@"project_id"] = @(projectId);
    
    if (queryId > 0) {
        paramsDic[@"query_id"] = @(queryId);
    }
    
    if (offset > 0) {
        paramsDic[@"offset"] = @(offset);
    }
    
    if (limit > 0) {
        paramsDic[@"limit"] = @(limit);
    }
    
    [self GET:@"/issues.json" params:paramsDic completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error) {
            if (completion) {
                completion(nil, 0, error);
            }
            
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError) {
            if (completion) {
                completion(nil, 0, jsonError);
            }
            
            return;
        }
        
        if (completion) {
            
            NSMutableArray *issues = [[NSMutableArray alloc] init];
            
            NSInteger totalCount = [responseObject[@"total_count"] integerValue];
            NSArray *issuesDic = [responseObject objectForKey:@"issues"];
            
            for (NSDictionary *p in issuesDic) {
                [issues addObject:[[OZLModelIssue alloc] initWithDictionary:p]];
            }
            
            completion(issues, totalCount, nil);
        }
    }];
}

- (void)getDetailForIssue:(NSInteger)issueid withParams:(NSDictionary *)params completion:(void (^)(OZLModelIssue *result, NSError *error))completion {
    
    NSString *path = [NSString stringWithFormat:@"/issues/%ld.json", (long)issueid];

    [self GET:path params:params completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError) {
            if (completion) {
                completion(nil, jsonError);
            }
            
            return;
        }

        if (completion) {

            NSDictionary *projectDic = [responseObject objectForKey:@"issue"];
            OZLModelIssue *issue = [[OZLModelIssue alloc] initWithDictionary:projectDic];

            completion(issue, nil);
        }
    }];
}

- (void)createIssue:(OZLModelIssue *)issueData withParams:(NSDictionary *)params completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    NSDictionary *issueDict = @{
        @"issue": issueData.changeDictionary
    };
    
    NSError *jsonError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:issueDict options:0 error:&jsonError];
    
    if (jsonError) {
        NSAssert(NO, @"Error serializing payload");
        
        if (completion) {
            completion(NO, jsonError);
        }
        
        return;
    }

    [self POST:@"/issues.json" bodyData:bodyData completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        BOOL success = (response.statusCode == 201 && !error);

        if (completion) {
            completion(success, error);
        }
    }];
}

- (void)updateIssue:(OZLModelIssue *)issueData withParams:(NSDictionary *)params completion:(void (^)(BOOL success, NSError *error))completion {
    
    NSString *path = [NSString stringWithFormat:@"/issues/%ld.json", (long)issueData.index];
    
    if (!issueData.changeDictionary) {
        completion(NO, [NSError errorWithDomain:OZLNetworkErrorDomain code:OZLNetworkErrorInvalidRequestBody userInfo:@{NSLocalizedDescriptionKey: @"The issue model passed didn't contain a change dictionary."}]);
        return;
    }

    //project info
    NSDictionary *issueDict = @{ @"issue": issueData.changeDictionary };
    
    NSError *jsonError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:issueDict options:0 error:&jsonError];
    
    if (jsonError) {
        NSAssert(NO, @"Error serializing payload");
        
        if (completion) {
            completion(NO, jsonError);
        }
        
        return;
    }

    [self PUT:path bodyData:bodyData completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        if (completion) {
            BOOL success = (response.statusCode == 200 && !error);
            
            completion(success, error);
        }
    }];
}

- (void)deleteIssue:(NSInteger)issueid withParams:(NSDictionary *)params completion:(void (^)(BOOL success, NSError *error))completion {
    
    NSString *path = [NSString stringWithFormat:@"/issues/%ld.json", (long)issueid];

    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }
    
    [self DELETE:path completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        if (completion) {
            BOOL success = (response.statusCode == 201 && !error);
            
            completion(success, nil);
        }
    }];
}

#pragma mark -
#pragma mark priority api
// priority
- (void)getPriorityListWithParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion {
    
    NSString *path = @"/enumerations/issue_priorities.json";
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];

    [self GET:path params:paramsDic completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError) {
            if (completion) {
                completion(nil, jsonError);
            }
            
            return;
        }

        if (completion) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"issue_priorities"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelIssuePriority alloc] initWithAttributeDictionary:p]];
            }
            
            completion(priorities, nil);
        }
    }];
}

#pragma mark -
#pragma mark issue status api
// issue status
- (void)getIssueStatusListWithParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion {
    
    NSString *path = @"/issue_statuses.json";
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];

    [self GET:path params:paramsDic completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError) {
            if (completion) {
                completion(nil, jsonError);
            }
            
            return;
        }

        if (completion) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"issue_statuses"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelIssueStatus alloc] initWithAttributeDictionary:p]];
            }
            
            completion(priorities, nil);
        }
    }];
}

#pragma mark - Queries
- (void)getQueryListForProject:(NSInteger)project params:(NSDictionary *)params completion:(void(^)(NSArray *result, NSError *error))completion {
    
    NSMutableDictionary *mutableParams;
    
    if (params) {
        mutableParams = [params mutableCopy];
    } else {
        mutableParams = [NSMutableDictionary dictionary];
    }
    
    if (!mutableParams[@"limit"]) {
        mutableParams[@"limit"] = @(100);
    }
    
    [self GET:@"/queries.json" params:mutableParams completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError) {
            if (completion) {
                completion(nil, jsonError);
            }
            
            return;
        }
        
        if (completion) {
            NSMutableArray *queries = [[NSMutableArray alloc] init];
            
            NSArray *dic = [responseObject objectForKey:@"queries"];
            dic = [dic filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"project_id = %ld", project]];
            
            for (NSDictionary *p in dic) {
                [queries addObject:[[OZLModelQuery alloc] initWithDictionary:p]];
            }
            
            completion(queries, nil);
        }
    }];
}

#pragma mark -
#pragma mark time entries
// time entries
- (void)getTimeEntriesWithParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion {
    
    NSString *path = @"/time_entries.json";
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];

    [self GET:path params:paramsDic completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError) {
            if (completion) {
                completion(nil, jsonError);
            }
            
            return;
        }

        if (completion) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"time_entries"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelTimeEntries alloc] initWithDictionary:p]];
            }
            
            completion(priorities, nil);
        }
    }];
}

- (void)getTimeEntriesForIssueId:(NSInteger)issueid withParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion {
    
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:issueid], @"issue_id", nil];
    [[OZLNetwork sharedInstance] getTimeEntriesWithParams:param completion:completion];
}

- (void)getTimeEntriesForProjectId:(NSInteger)projectid withParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion {

    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:projectid], @"project_id", nil];
    [[OZLNetwork sharedInstance] getTimeEntriesWithParams:param completion:completion];
}

- (void)getTimeEntryListWithParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion {
    
    NSString *path = @"/enumerations/time_entry_activities.json";
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];

    [self GET:path params:paramsDic completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError) {
            if (error) {
                completion(nil, jsonError);
            }
            
            return;
        }

        if (completion) {
            NSMutableArray *activities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"time_entry_activities"];
            
            for (NSDictionary *p in dic) {
                [activities addObject:[[OZLModelTimeEntryActivity alloc] initWithDictionary:p]];
            }
            
            completion(activities, nil);
        }
    }];
}

- (void)createTimeEntry:(OZLModelTimeEntries *)timeEntry withParams:(NSDictionary *)params completion:(void (^)(BOOL success, NSError *error))completion {
    
    NSString *path = [NSString stringWithFormat:@"/time_entries.json"];

    //project info
    NSDictionary *timeDict = [timeEntry toParametersDic];
    
    NSError *jsonError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:timeDict options:0 error:&jsonError];
    
    if (jsonError) {
        NSAssert(NO, @"Error serializing payload");
        completion(NO, jsonError);
        return;
    }

    [self POST:path bodyData:bodyData completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (completion) {
            BOOL success = (response.statusCode == 201 && !error);
            
            completion(success, nil);
        }
    }];
}

#pragma mark - Generic internal requests
- (void)GET:(NSString *)relativePath params:(NSDictionary *)params completion:(void(^)(NSData *responseData, NSHTTPURLResponse *response, NSError *error))completion {
    
    NSURL *url = [self urlWithRelativePath:relativePath];
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    
    NSString *queryString;
    BOOL isFirst = YES;
    
    for (NSString *key in params.allKeys) {
        NSString *value = params[key];
    
        if (isFirst) {
            queryString = [NSString stringWithFormat:@"%@=%@", key, value];
            isFirst = NO;
        } else {
            queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", key, value]];
        }
    }
    
    components.query = queryString;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
    request.HTTPMethod = @"GET";
    
    self.activeRequestCount += 1;
    
    __weak OZLNetwork *weakSelf = self;
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        weakSelf.activeRequestCount -= 1;
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                completion(data, httpResponse, error);
            });
        }
    }];
    
    [task resume];
}

- (void)POST:(NSString *)relativePath bodyData:(NSData *)bodyData completion:(void(^)(NSData * _Nullable responseData, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completion {
    
    NSURL *url = [self urlWithRelativePath:relativePath];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    self.activeRequestCount += 1;
    
    __weak OZLNetwork *weakSelf = self;
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        weakSelf.activeRequestCount -= 1;
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                completion(data, httpResponse, error);
            });
        }
    }];
    
    [task resume];
}

- (void)PUT:(NSString *)relativePath bodyData:(NSData *)bodyData completion:(void(^)(NSData *responseData, NSHTTPURLResponse *response, NSError *error))completion {
    
    NSURL *url = [self urlWithRelativePath:relativePath];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = bodyData;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    self.activeRequestCount += 1;
    
    __weak OZLNetwork *weakSelf = self;
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        weakSelf.activeRequestCount -= 1;
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                completion(data, httpResponse, error);
            });
        }
    }];
    
    [task resume];
}

- (void)DELETE:(NSString *)relativePath completion:(void(^)(NSData *responseData, NSHTTPURLResponse *response, NSError *error))completion {
    
    NSURL *url = [self urlWithRelativePath:relativePath];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"DELETE";
    
    self.activeRequestCount += 1;
    
    __weak OZLNetwork *weakSelf = self;
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        weakSelf.activeRequestCount -= 1;
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                completion(data, httpResponse, error);
            });
        }
    }];
    
    [task resume];
}

#pragma mark - NSURLSessionDelegate

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if ([task.originalRequest.URL.path isEqualToString:@"/login"]) {
        completionHandler(nil);
        return;
    }
    
    completionHandler(request);
}

@end
