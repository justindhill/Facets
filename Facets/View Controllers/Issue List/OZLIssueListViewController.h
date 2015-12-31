//
//  OZLIssueListViewController.h
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/14/13.

#import <UIKit/UIKit.h>
#import "OZLModelProject.h"
#import "OZLIssueListViewModel.h"

@interface OZLIssueListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, OZLIssueListViewModelDelegate>

@property (weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) id<OZLIssueListViewModel> viewModel;

@property (nonatomic, strong) OZLModelProject *projectData;

@property NSInteger projectId;
@property (strong, nonatomic) NSArray *trackerList;
@property (strong, nonatomic) NSArray *priorityList;
@property (strong, nonatomic) NSArray *statusList;
@property (strong, nonatomic) NSArray *userList;
@property (strong, nonatomic) NSArray *timeEntryActivityList;

@end
