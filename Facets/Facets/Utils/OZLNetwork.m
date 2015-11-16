//
//  OZLNetwork.m
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

#import "OZLNetwork.h"
#import "OZLSingleton.h"
#import "OZLURLProtocol.h"

NSString * const OZLNetworkErrorDomain = @"OZLNetworkErrorDomain";

@interface OZLNetwork () <NSURLSessionDelegate>

@property (strong) NSURLSession *urlSession;

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
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    
    return self;
}

- (NSURL *)urlWithRelativePath:(NSString *)path {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.baseURL resolvingAgainstBaseURL:YES];
    components.path = path;
    
    return components.URL;
}

#pragma mark - Authorization
- (void)validateCredentialsWithURL:(NSURL *)url username:(NSString *)username password:(NSString *)password completion:(void(^)(NSError *error))completion {
    
    NSAssert(completion, @"validateCredentialsCompletion: expects a completion block");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
        components.path = @"/users/current";
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
        
        NSString *credentials = [OZLNetwork encodedCredentialStringWithUsername:username password:password];
        [request setValue:[NSString stringWithFormat:@"Basic %@", credentials] forHTTPHeaderField:@"Authorization"];
        
        NSError *error;
        NSHTTPURLResponse *response;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSLog(@"response cookie: %@", response.allHeaderFields[@"Set-Cookie"]);
        NSLog(@"cookie iOS stored: %@", [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:components.URL] firstObject].value);
        NSError *reportError = error;
        
        if (response.statusCode == 401) {
            reportError = [NSError errorWithDomain:OZLNetworkErrorDomain code:OZLNetworkErrorInvalidCredentials userInfo:@{NSLocalizedDescriptionKey: @"Invalid username or password."}];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(reportError);
        });
    });
}

#pragma mark-
#pragma mark project api
- (void)getProjectListWithParams:(NSDictionary *)params andBlock:(void (^)(NSError *error))block {

    [self GET:@"/projects.json" params:params completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error && block) {
            block(error);
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError && block) {
            block(jsonError);
        }
        
        [[RLMRealm defaultRealm] beginWriteTransaction];
        
        NSArray *projectsDic = [responseObject objectForKey:@"projects"];
        
        for (NSDictionary *p in projectsDic) {
            OZLModelProject *project = [[OZLModelProject alloc] initWithDictionary:p];
            [OZLModelProject createOrUpdateInDefaultRealmWithValue:project];
        }
        
        [[RLMRealm defaultRealm] commitWriteTransaction];
        
        if (block) {
            block(nil);
        }
    }];
}

- (void)getDetailForProject:(NSInteger)projectid withParams:(NSDictionary *)params andBlock:(void (^)(OZLModelProject *result, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/projects/%ld.json", (long)projectid];
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:[self urlWithRelativePath:path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error && block) {
            block(nil, error);
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError && block) {
            block(nil, jsonError);
        }

        if (block) {

            NSDictionary *projectDic = [responseObject objectForKey:@"project"];
            OZLModelProject *project = [[OZLModelProject alloc] initWithDictionary:projectDic];

            block(project, nil);
        }
    }];
    
    [task resume];
}

- (void)createProject:(OZLModelProject *)projectData withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    //project info
    NSMutableDictionary *projectDic = [projectData toParametersDic];
    
    NSData *data;
    if (projectDic) {
        NSError *jsonError;
        data = [NSJSONSerialization dataWithJSONObject:projectDic options:0 error:&jsonError];
        
        NSAssert(!jsonError, @"Couldn't serialize payload");
    }
    
    [self POST:@"/projects.json" bodyData:data completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        if (block) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            BOOL success = (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 && !error);
            
            block(success, nil);
        }
    }];
}

- (void)updateProject:(OZLModelProject *)projectData withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/projects/%ld.json", (long)projectData.index];

    //project info
    NSMutableDictionary *projectDic = [projectData toParametersDic];
    
    NSData *data;
    if (projectDic) {
        NSError *jsonError;
        data = [NSJSONSerialization dataWithJSONObject:projectDic options:0 error:&jsonError];
        
        NSAssert(!jsonError, @"Couldn't serialize payload");
    }
    
    [self PUT:path bodyData:data completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        if (block) {
            BOOL success = (response.statusCode == 201 && !error);
            
            block(success, nil);
        }
    }];
}

- (void)deleteProject:(NSInteger)projectid withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/projects/%ld.json", (long)projectid];
    
    [self DELETE:path completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        if (block) {
            BOOL success = (response.statusCode == 201 && !error);
            
            block(success, nil);
        }
    }];
}

#pragma mark -
#pragma mark issue api
- (void)getIssueListForProject:(NSInteger)projectid withParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block {
    
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    [paramsDic setObject:[NSNumber numberWithInteger:projectid] forKey:@"project_id"];
    
    [self GET:@"/issues.json" params:paramsDic completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error && block) {
            block(nil, error);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError && block) {
            block(nil, jsonError);
            return;
        }

        if (block) {

            NSMutableArray *issues = [[NSMutableArray alloc] init];

            NSArray *issuesDic = [responseObject objectForKey:@"issues"];
            
            for (NSDictionary *p in issuesDic) {
                [issues addObject:[[OZLModelIssue alloc] initWithDictionary:p]];
            }
            
            block(issues, nil);
        }
    }];
}

- (void)getIssueListForQueryId:(NSInteger)queryId projectId:(NSInteger)projectId withParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/issues.json"];
    
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    paramsDic[@"project_id"] = @(projectId);
    paramsDic[@"query_id"] = @(queryId);
    
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:[self urlWithRelativePath:path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error && block) {
            block(nil, error);
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError && block) {
            block(nil, jsonError);
        }
        
        if (block) {
            
            NSMutableArray *issues = [[NSMutableArray alloc] init];
            
            NSArray *issuesDic = [responseObject objectForKey:@"issues"];
            
            for (NSDictionary *p in issuesDic) {
                [issues addObject:[[OZLModelIssue alloc] initWithDictionary:p]];
            }
            
            block(issues, nil);
        }
    }];
    
    [task resume];
}

- (void)getDetailForIssue:(NSInteger)issueid withParams:(NSDictionary *)params andBlock:(void (^)(OZLModelIssue *result, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/issues/%ld.json", (long)issueid];

    [self GET:path params:params completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error && block) {
            block(nil, error);
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError && block) {
            block(nil, jsonError);
        }

        if (block) {

            NSDictionary *projectDic = [responseObject objectForKey:@"issue"];
            OZLModelIssue *issue = [[OZLModelIssue alloc] initWithDictionary:projectDic];

            block(issue, nil);
        }
    }];
}

- (void)createIssue:(OZLModelIssue *)issueData withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    NSDictionary *issueDict = [issueData toParametersDic];
    
    NSError *jsonError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:issueDict options:0 error:&jsonError];
    
    if (jsonError) {
        NSAssert(NO, @"Error serializing payload");
        block(NO, jsonError);
        return;
    }

    [self POST:@"/issues.json" bodyData:bodyData completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        BOOL success = (response.statusCode == 201 && !error);

        if (block) {
            block(success, nil);
        }
    }];
}

- (void)updateIssue:(OZLModelIssue *)issueData withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/issues/%ld.json", (long)issueData.index];

    //project info
    NSDictionary *issueDict = [issueData toParametersDic];
    
    NSError *jsonError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:issueDict options:0 error:&jsonError];
    
    if (jsonError) {
        NSAssert(NO, @"Error serializing payload");
        block(NO, jsonError);
        return;
    }

    [self PUT:path bodyData:bodyData completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        if (block) {
            BOOL success = (response.statusCode == 201 && !error);
            
            block(success, nil);
        }
    }];
}

- (void)deleteIssue:(NSInteger)issueid withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/issues/%ld.json", (long)issueid];

    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }
    
    [self DELETE:path completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        if (block) {
            BOOL success = (response.statusCode == 201 && !error);
            
            block(success, nil);
        }
    }];
}

- (void)getJournalListForIssue:(NSInteger)issueid withParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/issues/%ld.json?include=journals", (long)issueid];
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:[self urlWithRelativePath:path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error && block) {
            block(nil, error);
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError && block) {
            block(nil, jsonError);
        }

        if (block) {

            NSMutableArray *journals = [[NSMutableArray alloc] init];

            NSArray *journalsDic = [[responseObject objectForKey:@"issue"] objectForKey:@"journals"];
            
            for (NSDictionary *p in journalsDic) {
                [journals addObject:[[OZLModelIssueJournal alloc] initWithDictionary:p]];
            }
            
            block(journals, nil);
        }
    }];
    
    [task resume];
}

#pragma mark -
#pragma mark priority api
// priority
- (void)getPriorityListWithParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block {
    
    NSString *path = @"/enumerations/issue_priorities.json";
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:[self urlWithRelativePath:path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error && block) {
            block(nil, error);
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError && block) {
            block(nil, jsonError);
        }

        if (block) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"issue_priorities"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelIssuePriority alloc] initWithDictionary:p]];
            }
            
            block(priorities, nil);
        }
    }];
    
    [task resume];
}

#pragma mark -
#pragma mark user api
// user
- (void)getUserListWithParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block {
    
    NSString *path = @"/users.json";
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:[self urlWithRelativePath:path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error && block) {
            block(nil, error);
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError && block) {
            block(nil, jsonError);
        }

        if (block) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"users"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelUser alloc] initWithDictionary:p]];
            }
            
            block(priorities, nil);
        }
    }];
    
    [task resume];
}

#pragma mark -
#pragma mark issue status api
// issue status
- (void)getIssueStatusListWithParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block {
    
    NSString *path = @"/issue_statuses.json";
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:[self urlWithRelativePath:path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error && block) {
            block(nil, error);
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError && block) {
            block(nil, jsonError);
        }

        if (block) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"issue_statuses"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelIssueStatus alloc] initWithDictionary:p]];
            }
            
            block(priorities, nil);
        }
    }];
    
    [task resume];
}

#pragma mark -
#pragma mark tracker api
// tracker
- (void)getTrackerListWithParams:(NSDictionary *)params andBlock:(void(^)(NSArray *result, NSError *error))block {
    
    NSString *path = @"/trackers.json";
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:[self urlWithRelativePath:path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error && block) {
            block(nil, error);
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError && block) {
            block(nil, jsonError);
        }

        if (block) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"trackers"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelTracker alloc] initWithDictionary:p]];
            }
            
            block(priorities, nil);
        }
    }];
    
    [task resume];
}

#pragma mark - Queries
- (void)getQueryListForProject:(NSInteger)project params:(NSDictionary *)params completion:(void(^)(NSArray *result, NSError *error))completion {
    
    [self GET:@"/queries.json" params:params completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (error && completion) {
            completion(nil, error);
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        if (jsonError && completion) {
            completion(nil, jsonError);
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
- (void)getTimeEntriesWithParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block {
    
    NSString *path = @"/time_entries.json";
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:[self urlWithRelativePath:path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error && block) {
            block(nil, error);
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError && block) {
            block(nil, jsonError);
        }

        if (block) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"time_entries"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelTimeEntries alloc] initWithDictionary:p]];
            }
            
            block(priorities, nil);
        }
    }];
    
    [task resume];
}

- (void)getTimeEntriesForIssueId:(NSInteger)issueid withParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block {
    
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:issueid], @"issue_id", nil];
    [[OZLNetwork sharedInstance] getTimeEntriesWithParams:param andBlock:block];
}

- (void)getTimeEntriesForProjectId:(NSInteger)projectid withParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block {

    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:projectid], @"project_id", nil];
    [[OZLNetwork sharedInstance] getTimeEntriesWithParams:param andBlock:block];
}

- (void)getTimeEntryListWithParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block {
    
    NSString *path = @"/enumerations/time_entry_activities.json";
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:[self urlWithRelativePath:path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error && block) {
            block(nil, error);
        }
        
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError && block) {
            block(nil, jsonError);
        }

        if (block) {
            NSMutableArray *activities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"time_entry_activities"];
            
            for (NSDictionary *p in dic) {
                [activities addObject:[[OZLModelTimeEntryActivity alloc] initWithDictionary:p]];
            }
            
            block(activities, nil);
        }
    }];
    
    [task resume];
}

- (void)createTimeEntry:(OZLModelTimeEntries *)timeEntry withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/time_entries.json"];

    //project info
    NSDictionary *timeDict = [timeEntry toParametersDic];
    
    NSError *jsonError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:timeDict options:0 error:&jsonError];
    
    if (jsonError) {
        NSAssert(NO, @"Error serializing payload");
        block(NO, jsonError);
        return;
    }

    [self POST:path bodyData:bodyData completion:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
        
        if (block) {
            BOOL success = (response.statusCode == 201 && !error);
            
            block(success, nil);
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
        } else {
            queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", key, value]];
        }
    }
    
    components.query = queryString;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                completion(data, httpResponse, error);
            });
        }
    }];
    
    [task resume];
}

- (void)POST:(NSString *)relativePath bodyData:(NSData *)bodyData completion:(void(^)(NSData *responseData, NSHTTPURLResponse *response, NSError *error))completion {
    
    NSURL *url = [self urlWithRelativePath:relativePath];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
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
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
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
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
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

@end
