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
#import "OZLModelMembership.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const OZLNetworkErrorDomain;

typedef NS_ENUM(NSInteger, OZLNetworkError) {
    OZLNetworkErrorInvalidCredentials,
    OZLNetworkErrorCouldntParseTokens,
    OZLNetworkErrorUnacceptableStatusCode,
    OZLNetworkErrorInvalidResponse,
    OZLNetworkErrorInvalidRequestBody
};

@interface OZLNetwork : NSObject

@property NSURL *baseURL;
@property (readonly) NSURLSession *urlSession;

+ (instancetype)sharedInstance;
+ (NSString *)encodedCredentialStringWithUsername:(NSString *)username password:(NSString *)password;

// Authorization
- (void)authenticateCredentialsWithURL:(NSURL *)url username:(NSString *)username password:(NSString *)password completion:(void(^)(NSError * _Nullable error))completion;
- (void)updateSessionCookieWithHost:(NSString *)host cookieHeader:(NSString *)cookieHeader;

// project 
- (void)getProjectListWithParams:(NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSError * _Nullable error))completion;
- (void)getCustomFieldsForProject:(NSInteger)project completion:(void (^)(NSArray<OZLModelCustomField *> * _Nullable fields, NSError * _Nullable error))completion;
- (void)getVersionsForProject:(NSInteger)project completion:(void (^)(NSArray<OZLModelVersion *> * _Nullable versions, NSError * _Nullable error))completion;
- (void)getMembershipsForProject:(NSInteger)project offset:(NSInteger)offset limit:(NSInteger)limit completion:(void (^)(NSArray<OZLModelMembership *> * _Nullable memberships, NSInteger totalCount, NSError * _Nullable error))completion;
- (void)deleteProject:(NSInteger)projectid withParams:(NSDictionary *)params completion:(void (^)(BOOL success, NSError * _Nullable error))completion;


// issue

- (void)getIssueListForProject:(NSInteger)projectid offset:(NSInteger)offset limit:(NSInteger)limit params:(nullable NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSInteger totalCount, NSError * _Nullable error))completion;
- (void)getIssueListForQueryId:(NSInteger)queryId projectId:(NSInteger)projectId offset:(NSInteger)offset limit:(NSInteger)limit params:(NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSInteger totalCount, NSError * _Nullable error))completion;
- (void)getDetailForIssue:(NSInteger)issueid withParams:(nullable NSDictionary *)params completion:(void (^)(OZLModelIssue * _Nullable result, NSError * _Nullable error))completion;
- (void)createIssue:(OZLModelIssue *)issueData withParams:(nullable NSDictionary *)params completion:(void (^)(BOOL success, NSError * _Nullable error))completion;
- (void)updateIssue:(OZLModelIssue *)issueData withParams:(nullable NSDictionary *)params completion:(void (^)(BOOL success, NSError * _Nullable error))completion;
- (void)deleteIssue:(NSInteger)issueid withParams:(nullable NSDictionary *)params completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

// priority
- (void)getPriorityListWithParams:(nullable NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSError * _Nullable error))completion;

// issue status
- (void)getIssueStatusListWithParams:(nullable NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSError * _Nullable error))completion;

// tracker
- (void)getTrackerListWithParams:(nullable NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSError * _Nullable error))completion;

// query list
- (void)getQueryListForProject:(NSInteger)project params:(nullable NSDictionary *)params completion:(void(^)(NSArray * _Nullable result, NSError * _Nullable error))completion;

// time entries
- (void)getTimeEntriesWithParams:(nullable NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSError * _Nullable error))completion;
- (void)getTimeEntriesForIssueId:(NSInteger)issueid withParams:(nullable NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSError * _Nullable error))completion;
- (void)getTimeEntriesForProjectId:(NSInteger)projectid withParams:(nullable NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSError * _Nullable error))completion;
- (void)getTimeEntryListWithParams:(nullable NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSError * _Nullable error))completion;
- (void)createTimeEntry:(OZLModelTimeEntries *)timeEntry withParams:(nullable NSDictionary *)params completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END