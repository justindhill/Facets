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
@property (copy) void (^completionBlock)(NSError *error);

@end

@implementation OZLServerSync

- (BOOL)isSyncing {
    return (self.activeCount > 0);
}

- (void)startSyncCompletion:(void(^)(NSError *error))completion {
    
    __weak OZLServerSync *weakSelf = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:OZLServerSyncDidBeginNotification object:nil];
    
    self.activeCount += 1;
    self.completionBlock = completion;
    
    [[OZLNetwork sharedInstance] getProjectListWithParams:nil andBlock:^(NSError *error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:OZLServerSyncDidFailNotification object:nil];
            
            return;
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
    }];
    
    self.activeCount += 1;
    [[OZLNetwork sharedInstance] getTrackerListWithParams:nil andBlock:^(NSArray *result, NSError *error) {
        weakSelf.activeCount -= 1;
    }];
}

- (void)checkForCompletion {
    if (self.activeCount == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:OZLServerSyncDidEndNotification object:nil];
        
        if (self.completionBlock) {
            self.completionBlock(nil);
            self.completionBlock = nil;
        }
    }
}

@end
