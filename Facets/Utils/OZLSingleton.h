//
//  OZLSingleton.h
//  Facets
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

//network
#warning Wowwww... move this sensitive information to the keychain.
@property (nonatomic, strong) NSString *redmineHomeURL;
@property (nonatomic, strong) NSString *redmineUserKey;
@property (nonatomic, strong) NSString *redmineUserName;
@property (nonatomic, strong) NSString *redminePassword;
@property (nonatomic, strong) NSString *redmineCookie;

//app status
@property (nonatomic) NSInteger currentProjectID;// last viewed project id
@property (readonly) BOOL isUserLoggedIn;

@end
