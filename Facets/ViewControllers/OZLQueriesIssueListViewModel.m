//
//  OZLQueriesIssueListViewModel.m
//  Facets
//
//  Created by Justin Hill on 11/4/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLQueriesIssueListViewModel.h"
#import "OZLNetwork.h"

@interface OZLQueriesIssueListViewModel ()

@property NSMutableArray *issues;
@property BOOL moreIssuesAvailable;
@property BOOL isLoading;

@end

@implementation OZLQueriesIssueListViewModel

@synthesize title;
@synthesize issues;

- (BOOL)shouldShowProjectSelector {
    return NO;
}

- (void)loadIssuesSortedBy:(NSString *)sortField ascending:(BOOL)ascending completion:(void (^)(NSError *))completion {
    __weak OZLQueriesIssueListViewModel *weakSelf = self;
    
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    [[OZLNetwork sharedInstance] getIssueListForQueryId:self.queryId projectId:self.projectId offset:0 limit:25 params:nil completion:^(NSArray *result, NSInteger totalCount, NSError *error) {
        
        weakSelf.isLoading = NO;
        weakSelf.moreIssuesAvailable = (weakSelf.issues.count < totalCount);
        
        weakSelf.issues = [result mutableCopy];
        weakSelf.moreIssuesAvailable = (weakSelf.issues.count < totalCount);
        completion(error);
    }];
}

- (void)loadMoreIssuesCompletion:(void (^)(NSError *))completion {
    __weak OZLQueriesIssueListViewModel *weakSelf = self;
    
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    [[OZLNetwork sharedInstance] getIssueListForProject:weakSelf.projectId offset:self.issues.count limit:25 params:nil completion:^(NSArray *result, NSInteger totalCount, NSError *error) {
        
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
    
    __weak OZLQueriesIssueListViewModel *weakSelf = self;
    [[OZLNetwork sharedInstance] deleteIssue:issue.index withParams:nil completion:^(BOOL success, NSError *error) {
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
