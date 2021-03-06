//
//  OZLNetwork.h
//  Facets
//
//  Created by Lee Zhijie on 7/14/13.

@import Foundation;
#import "OZLModelProject.h"
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
    OZLNetworkErrorInvalidRequestBody,
    OZLNetworkErrorInvalidParameter
};

@interface OZLNetwork : NSObject

@property NSURL *baseURL;
@property (readonly) NSURLSession *urlSession;

/**
 *  @brief If >0, the system network activity indicator becomes active. Be very careful when adjusting this value;
 *         typically, a change should only require a +1 or -1 to it.
 */
@property (nonatomic, assign) NSInteger activeRequestCount;

+ (instancetype)sharedInstance;
+ (NSString *)encodedCredentialStringWithUsername:(NSString *)username password:(NSString *)password;

// Authorization
- (void)authenticateCredentialsWithURL:(NSURL *)url username:(NSString *)username password:(NSString *)password completion:(void(^)(NSError * _Nullable error))completion;
- (void)updateSessionCookieWithHost:(NSString *)host cookieHeader:(NSString *)cookieHeader;

// project 
- (void)getProjectListWithParams:(NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSError * _Nullable error))completion;
- (void)getCustomFieldsForIssue:(NSInteger)issue completion:(void (^)(NSArray * _Nullable, NSError * _Nullable))completion;
- (void)getCustomFieldsForProject:(NSInteger)project completion:(void (^)(NSArray * _Nullable, NSError * _Nullable))completion;
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

// user
- (void)getCurrentUserWithCompletion:(void (^)(OZLModelUser *user, NSError *error))completion;
- (void)getUserWithId:(NSString *)userId completion:(void (^)(OZLModelUser *user, NSError *error))completion;

// priority
- (void)getPriorityListWithParams:(nullable NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSError * _Nullable error))completion;

// issue status
- (void)getIssueStatusListWithParams:(nullable NSDictionary *)params completion:(void (^)(NSArray * _Nullable result, NSError * _Nullable error))completion;

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
