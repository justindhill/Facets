//
//  OZLNetwork.h
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/14/13.

#import <Foundation/Foundation.h>
#import "OZLModelProject.h"
#import "OZLModelIssue.h"
#import "OZLModelIssuePriority.h"
#import "OZLModelIssueStatus.h"
#import "OZLModelTracker.h"
#import "OZLModelUser.h"
#import "OZLModelTimeEntries.h"
#import "OZLModelTimeEntryActivity.h"
#import "OZLModelCustomField.h"
#import "OZLModelVersion.h"

extern NSString * const OZLNetworkErrorDomain;

typedef NS_ENUM(NSInteger, OZLNetworkError) {
    OZLNetworkErrorInvalidCredentials,
    OZLNetworkErrorCouldntParseTokens,
    OZLNetworkErrorUnacceptableStatusCode,
    OZLNetworkErrorInvalidResponse
};

@interface OZLNetwork : NSObject

@property NSURL *baseURL;
@property (readonly) NSURLSession *urlSession;

+ (instancetype)sharedInstance;
+ (NSString *)encodedCredentialStringWithUsername:(NSString *)username password:(NSString *)password;

// Authorization
- (void)authenticateCredentialsWithURL:(NSURL *)url username:(NSString *)username password:(NSString *)password completion:(void(^)(NSError *error))completion;
- (void)updateSessionCookieWithHost:(NSString *)host cookieHeader:(NSString *)cookieHeader;

// project 
- (void)getProjectListWithParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion;
- (void)getCustomFieldsForProject:(NSInteger)project completion:(void (^)(NSArray<OZLModelCustomField *> *fields, NSError *error))completion;
- (void)getVersionsForProject:(NSInteger)project completion:(void (^)(NSArray<OZLModelVersion *> *versions, NSError *error))completion;
- (void)getMembershipsForProject:(NSInteger)project offset:(NSInteger)offset limit:(NSInteger)limit completion:(void (^)(NSArray<OZLModelMembership *> *memberships, NSInteger totalCount, NSError *error))completion;
- (void)deleteProject:(NSInteger)projectid withParams:(NSDictionary *)params completion:(void (^)(BOOL success, NSError *error))completion;


// issue

- (void)getIssueListForProject:(NSInteger)projectid offset:(NSInteger)offset limit:(NSInteger)limit params:(NSDictionary *)params completion:(void (^)(NSArray *result, NSInteger totalCount, NSError *error))completion;
- (void)getIssueListForQueryId:(NSInteger)queryId projectId:(NSInteger)projectId offset:(NSInteger)offset limit:(NSInteger)limit params:(NSDictionary *)params completion:(void (^)(NSArray *result, NSInteger totalCount, NSError *error))completion;
- (void)getDetailForIssue:(NSInteger)issueid withParams:(NSDictionary *)params completion:(void (^)(OZLModelIssue *result, NSError *error))completion;
- (void)createIssue:(OZLModelIssue *)issueData withParams:(NSDictionary *)params completion:(void (^)(BOOL success, NSError *error))completion;
- (void)updateIssue:(OZLModelIssue *)issueData withParams:(NSDictionary *)params completion:(void (^)(BOOL success, NSError *error))completion;
- (void)deleteIssue:(NSInteger)issueid withParams:(NSDictionary *)params completion:(void (^)(BOOL success, NSError *error))completion;

// priority
- (void)getPriorityListWithParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion;

// issue status
- (void)getIssueStatusListWithParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion;

// tracker
- (void)getTrackerListWithParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion;

// query list
- (void)getQueryListForProject:(NSInteger)project params:(NSDictionary *)params completion:(void(^)(NSArray *result, NSError *error))completion;

// time entries
- (void)getTimeEntriesWithParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion;
- (void)getTimeEntriesForIssueId:(NSInteger)issueid withParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion;
- (void)getTimeEntriesForProjectId:(NSInteger)projectid withParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion;
- (void)getTimeEntryListWithParams:(NSDictionary *)params completion:(void (^)(NSArray *result, NSError *error))completion;
- (void)createTimeEntry:(OZLModelTimeEntries *)timeEntry withParams:(NSDictionary *)params completion:(void (^)(BOOL success, NSError *error))completion;

@end
