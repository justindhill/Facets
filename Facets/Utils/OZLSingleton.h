//
//  OZLSingleton.h
//  Facets
//
//  Created by Lee Zhijie on 7/15/13.

@import Foundation;

@class OZLServerInfo;
@class OZLAttachmentManager;
@class JRAProject;

@interface OZLSingleton : NSObject

+ (OZLSingleton *)sharedInstance;

@property (readonly) OZLServerInfo *serverInfo;

//network
#warning Wowwww... move this sensitive information to the keychain.
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *cookie;

//app status
@property (readonly, strong) OZLAttachmentManager *attachmentManager;
@property (nonatomic) NSString *currentProjectID;// last viewed project id
@property (readonly) BOOL isUserLoggedIn;

@end
