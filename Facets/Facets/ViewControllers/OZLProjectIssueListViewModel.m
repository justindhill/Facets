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

@end

@implementation OZLProjectIssueListViewModel

@synthesize title;
@synthesize issues;

- (void)loadIssuesSortedBy:(NSString *)sortField ascending:(BOOL)ascending completion:(void (^)(NSError *))completion {
    
    // TODO: issue filter not working yet

    // prepare parameters
    OZLSingleton* singleton = [OZLSingleton sharedInstance];
    
    __weak OZLProjectIssueListViewModel *weakSelf = self;
    [[OZLNetwork sharedInstance] getDetailForProject:self.projectId withParams:nil andBlock:^(OZLModelProject *result, NSError *error) {
        if (error) {
            NSLog(@"error getDetailForProject: %@",error.description);
            completion(error);
        } else {
            weakSelf.title = result.name;

            // load issues
            [[OZLNetwork sharedInstance] getIssueListForProject:weakSelf.projectId withParams:nil andBlock:^(NSArray *result, NSError *error) {
                if (error) {
                    NSLog(@"error getIssueListForProject: %@",error.description);
                    completion(error);
                    
                } else {
                    weakSelf.issues = [result mutableCopy];
                    completion(nil);
                }
            }];
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
