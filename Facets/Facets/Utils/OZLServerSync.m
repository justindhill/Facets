//
//  OZLServerSync.m
//  Facets
//
//  Created by Justin Hill on 11/4/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLServerSync.h"
#import "OZLNetwork.h"

NSString * const OZLServerSyncDidBeginNotification = @"OZLServerSyncDidBeginNotification";
NSString * const OZLServerSyncDidFailNotification = @"OZLServerSyncDidFailNotification ";
NSString * const OZLServerSyncDidEndNotification = @"OZLServerSyncDidEndNotification ";

@interface OZLServerSync ()

@property NSInteger activeCount;

@end

@implementation OZLServerSync

- (BOOL)isSyncing {
    return (self.activeCount > 0);
}

- (void)startSync {
    
    __weak OZLServerSync *weakSelf = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:OZLServerSyncDidBeginNotification object:nil];
    
    self.activeCount += 1;
    [[OZLNetwork sharedInstance] getProjectListWithParams:nil andBlock:^(NSError *error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:OZLServerSyncDidFailNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:OZLServerSyncDidEndNotification object:nil];
        }
        
        weakSelf.activeCount -= 1;
    }];
}

@end
