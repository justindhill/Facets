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

@synthesize sortAndFilterOptions = _sortAndFilterOptions;
@synthesize delegate;
@synthesize title;
@synthesize issues;

- (instancetype)init {
    if (self = [super init]) {
        self.sortAndFilterOptions = [[OZLSortAndFilterOptions alloc] init];
    }
    
    return self;
}

- (BOOL)shouldShowComposeButton {
    return NO;
}

- (BOOL)shouldShowProjectSelector {
    return NO;
}

- (void)loadIssuesCompletion:(void (^)(NSError *))completion {
    __weak OZLQueriesIssueListViewModel *weakSelf = self;
    
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    NSDictionary *params = [self.sortAndFilterOptions requestParameters];
    
    [[OZLNetwork sharedInstance] getIssueListForQueryId:self.queryId projectId:self.projectId offset:0 limit:25 params:params completion:^(NSArray *result, NSInteger totalCount, NSError *error) {
        
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
    
    NSDictionary *params = [self.sortAndFilterOptions requestParameters];
    
    [[OZLNetwork sharedInstance] getIssueListForProject:weakSelf.projectId offset:self.issues.count limit:25 params:params completion:^(NSArray *result, NSInteger totalCount, NSError *error) {
        
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

- (void)processUpdatedIssue:(OZLModelIssue *)issue {
    NSInteger issueIndex = [self.issues indexOfObjectPassingTest:^BOOL(OZLModelIssue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return (issue.index == obj.index);
    }];
    
    if (issueIndex != NSNotFound) {
        [self.issues replaceObjectAtIndex:issueIndex withObject:issue];
        [self.delegate viewModelIssueListContentDidChange:self];
    }
}

- (void)setSortAndFilterOptions:(OZLSortAndFilterOptions *)sortAndFilterOptions {
    if (![sortAndFilterOptions isEqual:self.sortAndFilterOptions]) {
        self.issues = [NSMutableArray array];
    }
    
    _sortAndFilterOptions = sortAndFilterOptions;
}

#pragma mark - OZLQuickAssignDelegate
- (void)quickAssignController:(OZLQuickAssignViewController *)quickAssign didChangeAssigneeInIssue:(OZLModelIssue *)issue from:(OZLModelUser *)from to:(OZLModelUser *)to {
    [self processUpdatedIssue:issue];
}

@end
