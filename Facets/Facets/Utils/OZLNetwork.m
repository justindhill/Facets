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
#import "AFHTTPRequestOperation.h"
#import "OZLSingleton.h"

NSString * const OZLNetworkErrorDomain = @"OZLNetworkErrorDomain";

@interface OZLNetwork ()

@property AFHTTPClient *authorizationClient;

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

#pragma mark - Authorization
- (void)validateCredentialsWithURL:(NSURL *)url username:(NSString *)username password:(NSString *)password completion:(void(^)(NSError *error))completion {
    
    NSAssert(completion, @"validateCredentialsCompletion: expects a completion block");
    
    if (!self.authorizationClient) {
        self.authorizationClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    }
    
    [self.authorizationClient setAuthorizationHeaderWithUsername:username password:password];
    [self.authorizationClient getPath:@"users/current.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *reportError = error;
        
        if (operation.response.statusCode == 401) {
            reportError = [NSError errorWithDomain:OZLNetworkErrorDomain code:OZLNetworkErrorInvalidCredentials userInfo:@{NSLocalizedDescriptionKey: @"Invalid username or password."}];
        }
        
        completion(reportError);
    }];
    
}

#pragma mark-
#pragma mark project api
- (void)getProjectListWithParams:(NSDictionary *)params andBlock:(void (^)(NSError *error))block {
    NSString *path = @"/projects.json";
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (block) {
            block(error);
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

    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {

            NSDictionary *projectDic = [responseObject objectForKey:@"project"];
            OZLModelProject *project = [[OZLModelProject alloc] initWithDictionary:projectDic];

            block(project, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block(nil, error);
        }

    }];
}

- (void)createProject:(OZLModelProject *)projectData withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    NSString *path = @"/projects.json";

    //project info
    NSMutableDictionary *projectDic = [projectData toParametersDic];
    [projectDic addEntriesFromDictionary:params];
    
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [projectDic setObject:accessKey forKey:@"key"];
    }

    [[OZLSingleton sharedInstance].httpClient postPath:path parameters:projectDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            block(YES, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block(NO, error);
        }

    }];
}

- (void)updateProject:(OZLModelProject *)projectData withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/projects/%ld.json", (long)projectData.index];

    //project info
    NSMutableDictionary *projectDic = [projectData toParametersDic];
    [projectDic addEntriesFromDictionary:params];

    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [projectDic setObject:accessKey forKey:@"key"];
    }

    [[OZLSingleton sharedInstance].httpClient putPath:path parameters:projectDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            NSInteger repondNumber = [responseObject integerValue];
            block(repondNumber == 201, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block(NO, error);
        }
        
    }];

}

- (void)deleteProject:(NSInteger)projectid withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/projects/%ld.json", (long)projectid];
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    [[OZLSingleton sharedInstance].httpClient deletePath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            NSInteger repondNumber = [responseObject integerValue];
            block(repondNumber == 201, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block(NO, error);
        }
        
    }];

}

#pragma mark -
#pragma mark issue api
- (void)getIssueListForProject:(NSInteger)projectid withParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/issues.json"];
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    [paramsDic setObject:[NSNumber numberWithInteger:projectid] forKey:@"project_id"];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {

            NSMutableArray *issues = [[NSMutableArray alloc] init];

            NSArray *issuesDic = [responseObject objectForKey:@"issues"];
            
            for (NSDictionary *p in issuesDic) {
                [issues addObject:[[OZLModelIssue alloc] initWithDictionary:p]];
            }
            
            block(issues, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block([NSArray array], error);
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
    
    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (block) {
            
            NSMutableArray *issues = [[NSMutableArray alloc] init];
            
            NSArray *issuesDic = [responseObject objectForKey:@"issues"];
            
            for (NSDictionary *p in issuesDic) {
                [issues addObject:[[OZLModelIssue alloc] initWithDictionary:p]];
            }
            
            block(issues, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (block) {
            block([NSArray array], error);
        }
        
    }];
}

- (void)getDetailFoIssue:(NSInteger)issueid withParams:(NSDictionary *)params andBlock:(void (^)(OZLModelIssue *result, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/issues/%ld.json", (long)issueid];

    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {

            NSDictionary *projectDic = [responseObject objectForKey:@"issue"];
            OZLModelIssue *issue = [[OZLModelIssue alloc] initWithDictionary:projectDic];

            block(issue, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block(nil, error);
        }
        
    }];
}

- (void)createIssue:(OZLModelIssue *)issueData withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"/issues.json"];

    //project info
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    [paramsDic addEntriesFromDictionary:[issueData toParametersDic]];

    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    [[OZLSingleton sharedInstance].httpClient postPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            block(YES, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block(NO, error);
        }
        
    }];
}

- (void)updateIssue:(OZLModelIssue *)issueData withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/issues/%ld.json", (long)issueData.index];

    //project info
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    [paramsDic addEntriesFromDictionary:[issueData toParametersDic]];

    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    [[OZLSingleton sharedInstance].httpClient putPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            NSInteger repondNumber = [responseObject integerValue];
            block(repondNumber == 201, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block(NO, error);
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
    
    [[OZLSingleton sharedInstance].httpClient deletePath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            NSInteger repondNumber = [responseObject integerValue];
            block(repondNumber == 201, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block(NO, error);
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

    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {

            NSMutableArray *journals = [[NSMutableArray alloc] init];

            NSArray *journalsDic = [[responseObject objectForKey:@"issue"] objectForKey:@"journals"];
            
            for (NSDictionary *p in journalsDic) {
                [journals addObject:[[OZLModelIssueJournal alloc] initWithDictionary:p]];
            }
            
            block(journals, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block([NSArray array], error);
        }
        
    }];
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

    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"issue_priorities"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelIssuePriority alloc] initWithDictionary:p]];
            }
            
            block(priorities, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block([NSArray array], error);
        }
    }];
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

    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"users"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelUser alloc] initWithDictionary:p]];
            }
            
            block(priorities, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block([NSArray array], error);
        }
    }];
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

    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"issue_statuses"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelIssueStatus alloc] initWithDictionary:p]];
            }
            
            block(priorities, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block([NSArray array], error);
        }
    }];
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

    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"trackers"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelTracker alloc] initWithDictionary:p]];
            }
            
            block(priorities, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block([NSArray array], error);
        }
    }];
}

#pragma mark - Queries
- (void)getQueryListWithParams:(NSDictionary *)params andBlock:(void(^)(NSArray *result, NSError *error))block {
    
    NSString *path = @"/queries.json";
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }
    
    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (block) {
            NSMutableArray *queries = [[NSMutableArray alloc] init];
            
            NSArray *dic = [responseObject objectForKey:@"queries"];
            
            for (NSDictionary *p in dic) {
                [queries addObject:[[OZLModelQuery alloc] initWithDictionary:p]];
            }
            
            block(queries, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (block) {
            block([NSArray array], error);
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

    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            NSMutableArray *priorities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"time_entries"];
            
            for (NSDictionary *p in dic) {
                [priorities addObject:[[OZLModelTimeEntries alloc] initWithDictionary:p]];
            }
            
            block(priorities, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block([NSArray array], error);
        }
    }];

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

    [[OZLSingleton sharedInstance].httpClient getPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            NSMutableArray *activities = [[NSMutableArray alloc] init];

            NSArray *dic = [responseObject objectForKey:@"time_entry_activities"];
            
            for (NSDictionary *p in dic) {
                [activities addObject:[[OZLModelTimeEntryActivity alloc] initWithDictionary:p]];
            }
            
            block(activities, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block([NSArray array], error);
        }
    }];
}

- (void)createTimeEntry:(OZLModelTimeEntries *)timeEntry withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/time_entries.json"];

    //project info
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    [paramsDic addEntriesFromDictionary:[timeEntry toParametersDic]];

    NSString *accessKey = [[OZLSingleton sharedInstance] redmineUserKey];
    
    if (accessKey.length > 0) {
        [paramsDic setObject:accessKey forKey:@"key"];
    }

    [[OZLSingleton sharedInstance].httpClient postPath:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            block(YES, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (block) {
            block(NO, error);
        }
        
    }];
}

@end
