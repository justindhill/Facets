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
    
    NSDictionary *params = @{ @"include": @"trackers,issue_categories" };
    
    [[OZLNetwork sharedInstance] getProjectListWithParams:params andBlock:^(NSArray<OZLModelProject *> *result, NSError *error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:OZLServerSyncDidFailNotification object:nil];
            
            return;
        }
        
        RLMResults *allObjects = [OZLModelProject allObjects];
        
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            
            [[RLMRealm defaultRealm] deleteObjects:allObjects];
            
            for (OZLModelProject *project in result) {
                [OZLModelProject createOrUpdateInDefaultRealmWithValue:project];
            }
        }];
        
        BOOL updateCurrentProjectId = ([OZLSingleton sharedInstance].currentProjectID == NSNotFound);
        
        if (!updateCurrentProjectId) {
            // Make sure the current project still exists
            if (![OZLModelProject objectForPrimaryKey:@([OZLSingleton sharedInstance].currentProjectID)]) {
                updateCurrentProjectId = YES;
            }
        }
        
        if (updateCurrentProjectId) {
            OZLModelProject *newCurrentProject = [[OZLModelProject allObjects] sortedResultsUsingProperty:@"name" ascending:YES].firstObject;
            [OZLSingleton sharedInstance].currentProjectID = newCurrentProject ? newCurrentProject.projectId : NSNotFound;
        }
        
        for (OZLModelProject *project in allObjects) {
            NSLog(@"Fetching custom fields for \"%@\"", project.name);
            [weakSelf fetchCustomFieldsForProject:project.projectId];
            [weakSelf fetchVersionsForProject:project.projectId];
        }
        
        weakSelf.activeCount -= 1;
        [weakSelf checkForCompletion];
    }];
    
    self.activeCount += 1;
    [[OZLNetwork sharedInstance] getTrackerListWithParams:nil andBlock:^(NSArray *result, NSError *error) {
        if (!error) {
            [[RLMRealm defaultRealm] beginWriteTransaction];
            [[RLMRealm defaultRealm] deleteObjects:[OZLModelTracker allObjects]];
            [[RLMRealm defaultRealm] addObjects:result];
            [[RLMRealm defaultRealm] commitWriteTransaction];
        }
        
        weakSelf.activeCount -= 1;
        [weakSelf checkForCompletion];
    }];
}

- (void)fetchCustomFieldsForProject:(NSInteger)project {
    self.activeCount += 1;
    
    __weak OZLServerSync *weakSelf = self;
    [[OZLNetwork sharedInstance] getCustomFieldsForProject:project completion:^(NSArray<OZLModelCustomField *> *fields, NSError *error) {
        weakSelf.activeCount -= 1;
        
        [[RLMRealm defaultRealm] beginWriteTransaction];
        
        for (OZLModelCustomField *field in fields) {
            OZLModelCustomField *existingField = [OZLModelCustomField objectForPrimaryKey:@(field.fieldId)];
            
            // Just replace all the options currently in the store.
            if (existingField) {
                [[RLMRealm defaultRealm] deleteObjects:existingField.options];
            }
            
            [OZLModelCustomField createOrUpdateInDefaultRealmWithValue:field];
        }
        
        [[RLMRealm defaultRealm] commitWriteTransaction];
        
        [weakSelf checkForCompletion];
    }];
}

- (void)fetchVersionsForProject:(NSInteger)project {
    self.activeCount += 1;
    
    __weak OZLServerSync *weakSelf = self;
    [[OZLNetwork sharedInstance] getVersionsForProject:project completion:^(NSArray<OZLModelVersion *> *versions, NSError *error) {
        weakSelf.activeCount -= 1;
        
        [[RLMRealm defaultRealm] beginWriteTransaction];
        
        for (OZLModelVersion *version in versions) {
            [OZLModelVersion createOrUpdateInDefaultRealmWithValue:version];
        }
        
        [[RLMRealm defaultRealm] commitWriteTransaction];
        
        [weakSelf checkForCompletion];
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
