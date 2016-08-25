//
//  OZLServerSync.m
//  Facets
//
//  Created by Justin Hill on 11/4/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLServerInfo.h"
#import "OZLNetwork.h"
@import Jiramazing;

NSString * const OZLServerSyncDidBeginNotification = @"OZLServerSyncDidBeginNotification";
NSString * const OZLServerSyncDidFailNotification = @"OZLServerSyncDidFailNotification ";
NSString * const OZLServerSyncDidEndNotification = @"OZLServerSyncDidEndNotification ";

NSString * const OZLServerInfoCurrentProjectFileName = @"current_project.plist";
NSString * const OZLServerInfoProjectsFileName = @"projects.plist";

NSString * const OZLServerInfoCurrentServerHostUserDefaultsKey = @"com.facetsapp.serverinfo.CurrentServerHost";

@interface OZLServerInfo ()

@property NSInteger activeCount;
@property (copy) void (^completionBlock)(NSError *error);
@property NSString *storagePath;

@end

@implementation OZLServerInfo

- (instancetype)initWithStoragePath:(NSString *)storagePath {
    if (self = [super init]) {
        self.storagePath = storagePath;
        [self restoreState];
    }

    return self;
}

- (void)restoreState {
    self.currentServerHost = [[NSUserDefaults standardUserDefaults] objectForKey:OZLServerInfoCurrentServerHostUserDefaultsKey];

    NSString *serverFolder = self.serverFolderPath;

    if (serverFolder) {
        self.currentProject = [NSKeyedUnarchiver unarchiveObjectWithFile:[serverFolder stringByAppendingPathComponent:OZLServerInfoCurrentProjectFileName]];
        self.projects = [NSKeyedUnarchiver unarchiveObjectWithFile:[serverFolder stringByAppendingPathComponent:OZLServerInfoProjectsFileName]];
    }
}

- (NSString *)serverFolderPath {
    NSString *hostname = [Jiramazing sharedInstance].baseUrl.host;

    if (hostname) {
        return [self.storagePath stringByAppendingPathComponent:hostname];
    } else {
        return nil;
    }
}

- (BOOL)isSyncing {
    return (self.activeCount > 0);
}

- (void)startSyncCompletion:(void(^)(NSError *error))completion {

    NSString *serverFolder = self.serverFolderPath;

    if (![[NSFileManager defaultManager] fileExistsAtPath:serverFolder]) {
        NSError *createError;
        [[NSFileManager defaultManager] createDirectoryAtPath:serverFolder withIntermediateDirectories:YES attributes:nil error:&createError];

        if (createError) {
            completion([NSError errorWithDomain:@"OZLServerInfo" code:0
                        userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"OZLServerInfo: Couldn't create server directory - %@", createError.localizedDescription]}]);
            return;
        }
    }

    __weak OZLServerInfo *weakSelf = self;
    [[Jiramazing sharedInstance] getProjects:^(NSArray<JRAProject *> * _Nullable projects, NSError * _Nullable error) {
        if (error) {
            completion(error);
            return;
        }

        if (!weakSelf.currentProject) {
            weakSelf.currentProject = projects.firstObject;
        }

        weakSelf.projects = projects;

        NSString *projectsPath = [serverFolder stringByAppendingPathComponent:OZLServerInfoProjectsFileName];
        [NSKeyedArchiver archiveRootObject:projects toFile:projectsPath];

        completion(nil);
        [[NSNotificationCenter defaultCenter] postNotificationName:OZLServerSyncDidEndNotification object:nil];
    }];
}

- (void)setCurrentProject:(JRAProject *)currentProject {
    _currentProject = currentProject;

    NSString *serverFolder = self.serverFolderPath;
    NSString *projectPath = [serverFolder stringByAppendingPathComponent:OZLServerInfoCurrentProjectFileName];
    [NSKeyedArchiver archiveRootObject:currentProject toFile:projectPath];
}

@end
