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

@end

@implementation OZLQueriesIssueListViewModel

@synthesize title;
@synthesize issues;

- (void)loadIssuesSortedBy:(NSString *)sortField ascending:(BOOL)ascending completion:(void (^)(NSError *))completion {
    __weak OZLQueriesIssueListViewModel *weakSelf = self;
    [[OZLNetwork sharedInstance] getIssueListForQueryId:self.queryId projectId:self.projectId withParams:nil andBlock:^(NSArray *result, NSError *error) {
        weakSelf.issues = [result mutableCopy];
        completion(error);
    }];
}

- (void)deleteIssueAtIndex:(NSInteger)index completion:(void (^)(NSError *))completion {
    NSAssert(index >= 0 && index < self.issues.count, @"index out of range");
    
    OZLModelIssue *issue = self.issues[index];
    
    __weak OZLQueriesIssueListViewModel *weakSelf = self;
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
