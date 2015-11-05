//
//  OZLIssueListViewModel.h
//  Facets
//
//  Created by Justin Hill on 11/4/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OZLIssueListViewModel

@property NSInteger projectId;
@property NSString *title;
@property (readonly) NSArray *issues;
@property (readonly) BOOL shouldShowProjectSelector;

- (void)loadIssuesSortedBy:(NSString *)sortField ascending:(BOOL)ascending completion:(void(^)(NSError *error))completion;
- (void)deleteIssueAtIndex:(NSInteger)index completion:(void(^)(NSError *error))completion;

@optional
@property (readonly) RLMResults *projects;
- (void)refreshProjectList;

@end
