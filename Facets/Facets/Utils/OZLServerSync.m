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

- (void)startSyncCompletion:(void(^)(NSError *error))completion {
    
#warning This is gonna need a lot of love when we start syncing more stuff about the server.
    
    __weak OZLServerSync *weakSelf = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:OZLServerSyncDidBeginNotification object:nil];
    
    self.activeCount += 1;
    [[OZLNetwork sharedInstance] getProjectListWithParams:nil andBlock:^(NSError *error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:OZLServerSyncDidFailNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:OZLServerSyncDidEndNotification object:nil];
        }
        
        BOOL updateCurrentProjectId = ([OZLSingleton sharedInstance].currentProjectID == NSNotFound);
        if ([OZLSingleton sharedInstance].currentProjectID != NSNotFound) {
            // Make sure the current project still exists
            if (![OZLModelProject objectForPrimaryKey:@([OZLSingleton sharedInstance].currentProjectID)]) {
                updateCurrentProjectId = YES;
            }
        }
        
        if (updateCurrentProjectId) {
            OZLModelProject *newCurrentProject = [[OZLModelProject allObjects] sortedResultsUsingProperty:@"name" ascending:YES].firstObject;
            [OZLSingleton sharedInstance].currentProjectID = newCurrentProject ? newCurrentProject.index : NSNotFound;
        }
        
        weakSelf.activeCount -= 1;
        
        if (completion) {
            completion(error);
        }
    }];
}

@end
