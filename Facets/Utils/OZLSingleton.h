//
//  OZLSingleton.h
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/15/13.

#import <Foundation/Foundation.h>
#import "OZLModelTracker.h"
#import "OZLModelUser.h"
#import "OZLModelIssueStatus.h"
#import "OZLModelIssuePriority.h"
#import "OZLModelQuery.h"
#import "OZLServerSync.h"

@interface OZLSingleton : NSObject

+ (OZLSingleton *)sharedInstance;

@property (readonly) OZLServerSync *serverSync;

@property (nonatomic, readonly) NSURLSession *urlSession;

//network
@property (nonatomic, strong) NSString *redmineHomeURL;
@property (nonatomic, strong) NSString *redmineUserKey;
@property (nonatomic, strong) NSString *redmineUserName;
@property (nonatomic, strong) NSString *redminePassword;

// issue list option
@property (nonatomic) NSInteger issueListFilterType;
@property (nonatomic) NSInteger issueListSortType;
@property (nonatomic) NSInteger issueListSortAscending;

//app status
@property (nonatomic) NSInteger currentProjectID;// last viewed project id

// app data
@property (strong, nonatomic) NSArray *trackerList;
@property (strong, nonatomic) NSArray *priorityList;
@property (strong, nonatomic) NSArray *statusList;
@property (strong, nonatomic) NSArray *userList;
@property (strong, nonatomic) NSArray *timeEntryActivityList;

- (OZLModelTracker *)trackerWithId:(NSInteger)index;
- (OZLModelIssuePriority *)issuePriorityWithId:(NSInteger)index;
- (OZLModelIssueStatus *)issueStatusWithId:(NSInteger)index;
- (OZLModelUser *)userWithId:(NSInteger)index;

@property (readonly) BOOL isUserLoggedIn;

@end
