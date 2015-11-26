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

@end

@implementation OZLProjectIssueListViewModel

@synthesize projectId = _projectId;
@synthesize title;
@synthesize issues;
@synthesize projects;

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
    _projectId = projectId;
    [OZLSingleton sharedInstance].currentProjectID = projectId;
}

- (void)loadIssuesSortedBy:(NSString *)sortField ascending:(BOOL)ascending completion:(void (^)(NSError *))completion {
    
    __weak OZLProjectIssueListViewModel *weakSelf = self;

    // load issues
    [[OZLNetwork sharedInstance] getIssueListForProject:weakSelf.projectId withParams:nil andBlock:^(NSArray *result, NSError *error) {
        if (error) {
            NSLog(@"error getIssueListForProject: %@", error.description);
            completion(error);
            
        } else {
            weakSelf.issues = [result mutableCopy];
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
