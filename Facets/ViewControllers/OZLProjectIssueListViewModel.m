//
//  OZLProjectIssueListViewModel.m
//  Facets
//
//  Created by Justin Hill on 11/4/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLProjectIssueListViewModel.h"
#import "OZLModelIssue.h"
#import "OZLNetwork.h"

@interface OZLProjectIssueListViewModel ()

@property NSMutableArray *issues;
@property RLMResults *projects;
@property BOOL moreIssuesAvailable;
@property BOOL isLoading;

@end

@implementation OZLProjectIssueListViewModel

@synthesize projectId = _projectId;
@synthesize title;
@synthesize issues;
@synthesize projects;

- (instancetype)init {
    if (self = [super init]) {
        self.moreIssuesAvailable = YES;
    }
    
    return self;
}

- (BOOL)shouldShowProjectSelector {
    return YES;
}

- (void)refreshProjectList {
    self.projects = [[OZLModelProject allObjects] sortedResultsUsingProperty:@"name" ascending:YES];
}

- (NSString *)title {
    return [OZLModelProject objectForPrimaryKey:@(self.projectId)].name;
}

- (void)setTitle:(NSString *)title {
    NSAssert(NO, @"This issue list view model doesn't support setting a custom title");
}

- (void)setProjectId:(NSInteger)projectId {
    if (projectId != _projectId) {
        self.issues = [NSMutableArray array];
        [OZLSingleton sharedInstance].currentProjectID = projectId;
    }
    
    _projectId = projectId;
}

- (void)loadIssuesSortedBy:(NSString *)sortField ascending:(BOOL)ascending completion:(void (^)(NSError *error))completion {
    
    __weak OZLProjectIssueListViewModel *weakSelf = self;
    
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;

    // load issues
    [[OZLNetwork sharedInstance] getIssueListForProject:weakSelf.projectId offset:0 limit:25 params:nil andBlock:^(NSArray *result, NSInteger totalCount, NSError *error) {
        
        weakSelf.isLoading = NO;
        weakSelf.moreIssuesAvailable = (weakSelf.issues.count < totalCount);
        
        if (error) {
            NSLog(@"error getIssueListForProject: %@", error.description);
            completion(error);
            
        } else {
            weakSelf.issues = [result mutableCopy];
            completion(nil);
        }
    }];
}

- (void)loadMoreIssuesCompletion:(void(^)(NSError *error))completion {
    
    __weak OZLProjectIssueListViewModel *weakSelf = self;
    
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    [[OZLNetwork sharedInstance] getIssueListForProject:weakSelf.projectId offset:self.issues.count limit:25 params:nil andBlock:^(NSArray *result, NSInteger totalCount, NSError *error) {
        
        weakSelf.isLoading = NO;
        weakSelf.moreIssuesAvailable = (weakSelf.issues.count < totalCount);
        
        if (error) {
            NSLog(@"error getIssueListForProject: %@", error.description);
            completion(error);
            
        } else {
            weakSelf.issues = [[weakSelf.issues arrayByAddingObjectsFromArray:result] mutableCopy];
            completion(nil);
        }
    }];
}

- (void)deleteIssueAtIndex:(NSInteger)index completion:(void (^)(NSError *))completion {
    NSAssert(index >= 0 && index < self.issues.count, @"index out of range");
    
    OZLModelIssue *issue = self.issues[index];
    
    __weak OZLProjectIssueListViewModel *weakSelf = self;
    [[OZLNetwork sharedInstance] deleteIssue:issue.index withParams:nil andBlock:^(BOOL success, NSError *error) {
        if (completion) {
            if (error) {
                completion(error);
                
            } else {
                [weakSelf.issues removeObjectAtIndex:index];
            }
        }
    }];
}

@end
