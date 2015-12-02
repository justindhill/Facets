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

// project 
- (void)getProjectListWithParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block;
- (void)getDetailForProject:(NSInteger)projectid withParams:(NSDictionary *)params andBlock:(void (^)(OZLModelProject *result, NSError *error))block;
- (void)getCustomFieldsForProject:(NSInteger)project completion:(void (^)(NSArray<OZLModelCustomField *> *fields, NSError *error))completion;
- (void)createProject:(OZLModelProject *)projectData withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block;
- (void)updateProject:(OZLModelProject *)projectData withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block;
- (void)deleteProject:(NSInteger)projectid withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block;


// issue

- (void)getIssueListForProject:(NSInteger)projectid offset:(NSInteger)offset limit:(NSInteger)limit params:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSInteger totalCount, NSError *error))block;
- (void)getIssueListForQueryId:(NSInteger)queryId projectId:(NSInteger)projectId offset:(NSInteger)offset limit:(NSInteger)limit params:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSInteger totalCount, NSError *error))block;
- (void)getDetailForIssue:(NSInteger)issueid withParams:(NSDictionary *)params andBlock:(void (^)(OZLModelIssue *result, NSError *error))block;
- (void)createIssue:(OZLModelIssue *)issueData withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block;
- (void)updateIssue:(OZLModelIssue *)issueData withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block;
- (void)deleteIssue:(NSInteger)issueid withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block;

// priority
- (void)getPriorityListWithParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block;

// user
- (void)getUserListWithParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block;

// issue status
- (void)getIssueStatusListWithParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block;

// tracker
- (void)getTrackerListWithParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block;

// query list
- (void)getQueryListForProject:(NSInteger)project params:(NSDictionary *)params completion:(void(^)(NSArray *result, NSError *error))completion;

// time entries
- (void)getTimeEntriesWithParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block;
- (void)getTimeEntriesForIssueId:(NSInteger)issueid withParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block;
- (void)getTimeEntriesForProjectId:(NSInteger)projectid withParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block;
- (void)getTimeEntryListWithParams:(NSDictionary *)params andBlock:(void (^)(NSArray *result, NSError *error))block;
- (void)createTimeEntry:(OZLModelTimeEntries *)timeEntry withParams:(NSDictionary *)params andBlock:(void (^)(BOOL success, NSError *error))block;

@end
