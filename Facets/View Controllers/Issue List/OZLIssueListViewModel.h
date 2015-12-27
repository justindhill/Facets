//
//  OZLIssueListViewModel.h
//  Facets
//
//  Created by Justin Hill on 11/4/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OZLIssueListViewModel;
@protocol OZLIssueListViewModelDelegate <NSObject>

- (void)viewModelIssueListContentDidChange:(id<OZLIssueListViewModel>)viewModel;

@end

@protocol OZLIssueListViewModel <OZLQuickAssignDelegate>

@property (weak) id<OZLIssueListViewModelDelegate> delegate;
@property NSInteger projectId;
@property NSString *title;
@property (readonly) NSArray *issues;
@property (readonly) BOOL shouldShowProjectSelector;
@property (readonly) BOOL shouldShowComposeButton;
@property (readonly) BOOL moreIssuesAvailable;
@property (readonly) BOOL isLoading;

- (void)loadIssuesSortedBy:(NSString *)sortField ascending:(BOOL)ascending completion:(void(^)(NSError *error))completion;
- (void)loadMoreIssuesCompletion:(void(^)(NSError *error))completion;
- (void)deleteIssueAtIndex:(NSInteger)index completion:(void(^)(NSError *error))completion;
- (void)processUpdatedIssue:(OZLModelIssue *)issue;

@optional
@property (readonly) RLMResults *projects;
- (void)refreshProjectList;

@end
