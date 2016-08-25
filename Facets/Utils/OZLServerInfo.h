//
//  OZLServerSync.h
//  Facets
//
//  Created by Justin Hill on 11/4/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import Foundation;

@class JRAProject;

extern NSString * const OZLServerSyncDidBeginNotification;
extern NSString * const OZLServerSyncDidFailNotification;
extern NSString * const OZLServerSyncDidEndNotification;

@interface OZLServerInfo : NSObject

- (instancetype)initWithStoragePath:(NSString *)storagePath;
@property (strong) NSString *currentServerHost;

@property (nonatomic, strong) JRAProject *currentProject;
@property (strong) NSArray<JRAProject *> *projects;

@property (readonly) BOOL isSyncing;
- (void)startSyncCompletion:(void(^)(NSError *error))completion;

@end
