//
//  OZLServerSync.h
//  Facets
//
//  Created by Justin Hill on 11/4/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import Foundation;

extern NSString * const OZLServerSyncDidBeginNotification;
extern NSString * const OZLServerSyncDidFailNotification;
extern NSString * const OZLServerSyncDidEndNotification;

@interface OZLServerSync : NSObject

@property (readonly) BOOL isSyncing;
- (void)startSyncCompletion:(void(^)(NSError *error))completion;

@end
