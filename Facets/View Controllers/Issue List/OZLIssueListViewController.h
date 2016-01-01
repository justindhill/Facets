//
//  OZLIssueListViewController.h
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/14/13.

#import <UIKit/UIKit.h>
#import "OZLModelProject.h"

@class OZLIssueListViewModel;
@protocol OZLIssueListViewModelDelegate;
@interface OZLIssueListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, OZLIssueListViewModelDelegate>

@property (weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) OZLIssueListViewModel *viewModel;

@property (nonatomic, strong) OZLModelProject *projectData;

@property NSInteger projectId;
@property (strong, nonatomic) NSArray *trackerList;
@property (strong, nonatomic) NSArray *priorityList;
@property (strong, nonatomic) NSArray *statusList;
@property (strong, nonatomic) NSArray *userList;
@property (strong, nonatomic) NSArray *timeEntryActivityList;

@end
