//
//  OZLServerSync.m
//  Facets
//
//  Created by Justin Hill on 11/4/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLServerSync.h"
#import "OZLNetwork.h"
@import Jiramazing;

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

    [[Jiramazing sharedInstance] getProjects:^(NSArray<JRAProject *> * _Nullable projects, NSError * _Nullable error) {
        if (error) {
            completion(error);
            return;
        }

        [OZLSingleton sharedInstance].projects = projects;

        NSString *documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES).firstObject;

        if (documentsDirectoryPath) {
            NSString *projectsPath = [documentsDirectoryPath stringByAppendingPathComponent:@"projects.plist"];
            [NSKeyedArchiver archiveRootObject:projectsPath toFile:projectsPath];
        }

        completion(nil);
    }];
}

@end
