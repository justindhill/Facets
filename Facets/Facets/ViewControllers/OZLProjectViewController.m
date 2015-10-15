//
//  OZLProjectViewController.m
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/14/13.

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2013 Zhijie Lee(onezeros.lee@gmail.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "OZLProjectViewController.h"
#import "OZLProjectListViewController.h"
#import "OZLNetwork.h"
#import "MBProgressHUD.h"
#import "OZLProjectInfoViewController.h"
#import "OZLIssueDetailViewController.h"
#import "OZLIssueCreateOrUpdateViewController.h"
#import "OZLIssueFilterViewController.h"
#import "OZLSingleton.h"

#import "Facets-Swift.h"

@interface OZLProjectViewController () <UIViewControllerPreviewingDelegate> {
    NSMutableArray* _issuesList;

    float _sideviewOffset;
    MBProgressHUD * _HUD;
    UIBarButtonItem* _editBtn;
    UIBarButtonItem* _doneBtn;

    NSMutableDictionary* _issueListOption;
}

@property BOOL isFirstAppearance;
@property CAPSOptionsMenu *optionsMenu;

@end

@implementation OZLProjectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isFirstAppearance = YES;
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editIssueListDone:)];

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:_HUD];
	_HUD.labelText = @"Loading...";
    
    [[OZLSingleton sharedInstance] setLastProjectID:_projectData.index];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Check for force touch feature, and add force touch/previewing capability.
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isFirstAppearance) {
        [self reloadData];
        
        self.optionsMenu = [[CAPSOptionsMenu alloc] initWithViewController:self barButtonSystemItem:UIBarButtonSystemItemAction keepBarButtonAtEdge:NO];
    
        __weak OZLProjectViewController *weakSelf = self;
        [self.optionsMenu addAction:[[CAPSOptionsMenuAction alloc] initWithTitle:@"Edit" handler:^(CAPSOptionsMenuAction * _Nonnull action) {
            [weakSelf editIssueList:nil];
        }]];
        
        [self.optionsMenu addAction:[[CAPSOptionsMenuAction alloc] initWithTitle:@"Sort" handler:^(CAPSOptionsMenuAction * _Nonnull action) {
        }]];
        
        [self.optionsMenu addAction:[[CAPSOptionsMenuAction alloc] initWithTitle:@"Copy Link" handler:^(CAPSOptionsMenuAction * _Nonnull action) {
        }]];
    }
    
    self.isFirstAppearance = NO;
}

- (void)reloadData
{
    if (_projectData == nil) {
        NSLog(@"error: _projectData have to be set");
        return;
    }
    
    if (!self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }

    if (_issueListOption == nil) {
        [self loadIssueRelatedData];
    }else {
        [self loadProjectDetail];
    }
}

-(void)loadProjectDetail
{
    // TODO: issue filter not working yet

    // prepare parameters
    OZLSingleton* singleton = [OZLSingleton sharedInstance];
    
    // meaning of these values is defined in OZLIssueFilterViewController
    NSInteger filterType = [singleton issueListFilterType];
    
    if (filterType == 1) {
        // open
        [_issueListOption setObject:@"open" forKey:@"status_id"];
    }
    
    [OZLNetwork getDetailForProject:_projectData.index withParams:nil andBlock:^(OZLModelProject *result, NSError *error) {
        if (error) {
            NSLog(@"error getDetailForProject: %@",error.description);
            [self.refreshControl endRefreshing];
        }else {
            _projectData = result;

            // load issues
            [OZLNetwork getIssueListForProject:_projectData.index withParams:_issueListOption andBlock:^(NSArray *result, NSError *error) {
                if (error) {
                    NSLog(@"error getIssueListForProject: %@",error.description);
                    
                } else {
                    _issuesList = [[NSMutableArray alloc] initWithArray: result];
                    [self.tableView reloadData];
                }
                [self.refreshControl endRefreshing];
            }];
        }
    }];
}

-(void)loadIssueRelatedData
{
    _issueListOption = [[NSMutableDictionary alloc] init];

    OZLSingleton* singleton = [OZLSingleton sharedInstance];
    if (singleton.userList != nil) {
        _trackerList = singleton.trackerList;
        _statusList = singleton.statusList;
        _userList = singleton.userList;
        _priorityList = singleton.priorityList;
        _timeEntryActivityList = singleton.timeEntryActivityList;
        [self loadProjectDetail];
    }else {
        static int doneCount = 0;
        const int totalCount = 5;
        [OZLNetwork getTrackerListWithParams:nil andBlock:^(NSArray *result, NSError *error) {
            if (!error) {
                _trackerList = result;
                singleton.trackerList = _trackerList;
            }else {
                NSLog(@"get tracker list error : %@",error.description);
            }
            doneCount ++;
            if (doneCount == totalCount) {
                [self loadProjectDetail];
                doneCount = 0;
            }
        }];

        [OZLNetwork getIssueStatusListWithParams:nil andBlock:^(NSArray *result, NSError *error) {
            if (!error) {
                _statusList = result;
                singleton.statusList = _statusList;
            }else {
                NSLog(@"get issue status list error : %@",error.description);
            }
            doneCount ++;
            if (doneCount == totalCount) {
                [self loadProjectDetail];
                doneCount = 0;
            }
        }];
        [OZLNetwork getPriorityListWithParams:nil andBlock:^(NSArray *result, NSError *error) {
            if (!error) {
                _priorityList = result;
                singleton.priorityList = _priorityList;
            }else {
                NSLog(@"get priority list error : %@",error.description);
            }
            doneCount ++;
            if (doneCount == totalCount) {
                [self loadProjectDetail];
                doneCount = 0;
            }
        }];
        [OZLNetwork getUserListWithParams:nil andBlock:^(NSArray *result, NSError *error) {
            if (!error) {
                _userList = result;
                singleton.userList = _userList;
            }else {
                NSLog(@"get user list error : %@",error.description);
            }
            doneCount ++;
            if (doneCount == totalCount) {
                [self loadProjectDetail];
                doneCount = 0;
            }
        }];

        [OZLNetwork getTimeEntryListWithParams:nil andBlock:^(NSArray *result, NSError *error) {
            if (!error) {
                _timeEntryActivityList = result;
                singleton.timeEntryActivityList = _timeEntryActivityList;
            }else {
                NSLog(@"get user list error : %@",error.description);
            }
            doneCount ++;
            if (doneCount == totalCount) {
                [self loadProjectDetail];
                doneCount = 0;
            }
        }];
    }
}

- (void)showProjectList {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Accessors
- (void)setProjectData:(OZLModelProject *)projectData {
    _projectData = projectData;

    self.navigationItem.title = _projectData.name;
}

#pragma mark - Actions
- (void)refreshAction:(UIRefreshControl *)refreshControl {
    [self reloadData];
}

#pragma mark - Previewing
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    UIStoryboard *tableViewStoryboard = [UIStoryboard storyboardWithName:@"OZLIssueDetailViewController" bundle:nil];
    OZLIssueDetailViewController* detail = [tableViewStoryboard instantiateViewControllerWithIdentifier:@"OZLIssueDetailViewController"];
    [detail setIssueData:[_issuesList objectAtIndex:indexPath.row]];
    
    return detail;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_issuesList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellidentifier = [NSString stringWithFormat:@"issue_cell_id"];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellidentifier];
    }
    
    OZLModelIssue* issue = [_issuesList objectAtIndex:indexPath.row];
    cell.textLabel.text = issue.subject;
    cell.detailTextLabel.text = issue.description;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        _HUD.labelText = @"Deleting Issue...";
        _HUD.detailsLabelText = @"";
        _HUD.mode = MBProgressHUDModeIndeterminate;
        [_HUD show:YES];
        [OZLNetwork deleteIssue:[[_issuesList objectAtIndex:indexPath.row] index] withParams:nil andBlock:^(BOOL success, NSError *error) {
            if (error) {
                NSLog(@"failed to delete issue");
                _HUD.mode = MBProgressHUDModeText;
                _HUD.labelText = @"Connection Failed";
                _HUD.detailsLabelText = @" Please check network connection or your account setting.";
                [_HUD hide:YES afterDelay:3];
            }else {
                [_issuesList removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [_HUD hide:YES];
            }
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //OZLIssueDetailViewController* detail = [[OZLIssueDetailViewController alloc] initWithNibName:@"OZLIssueDetailViewController" bundle:nil];
    UIStoryboard *tableViewStoryboard = [UIStoryboard storyboardWithName:@"OZLIssueDetailViewController" bundle:nil];
    OZLIssueDetailViewController* detail = [tableViewStoryboard instantiateViewControllerWithIdentifier:@"OZLIssueDetailViewController"];
    [detail setIssueData:[_issuesList objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detail animated:YES];
}

- (IBAction)onNewIssue:(id)sender {
    if (![OZLSingleton isUserLoggedIn] ) {
        _HUD.mode = MBProgressHUDModeText;
        _HUD.labelText = @"No available";
        _HUD.detailsLabelText = @"You need to log in to do this.";
        [_HUD show:YES];
        [_HUD hide:YES afterDelay:2];
        return;
    }
    
    UIStoryboard *tableViewStoryboard = [UIStoryboard storyboardWithName:@"OZLIssueCreateOrUpdateViewController" bundle:nil];
    OZLIssueCreateOrUpdateViewController* creator = [tableViewStoryboard instantiateViewControllerWithIdentifier:@"OZLIssueCreateOrUpdateViewController"];
    [creator setParentProject:_projectData];
    [creator setViewMode:OZLIssueInfoViewModeCreate];
    
    [self.navigationController pushViewController:creator animated:YES];
}

- (IBAction)onShowInfo:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OZLProjectInfoViewController" bundle:nil];
    OZLProjectInfoViewController* detail = [storyboard instantiateViewControllerWithIdentifier:@"OZLProjectInfoViewController"];
    [detail setProjectData:_projectData];
    [detail setViewMode:OZLProjectInfoViewModeDisplay];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)editIssueList:(id)sender {
    if (![OZLSingleton isUserLoggedIn]) {
        _HUD.mode = MBProgressHUDModeText;
        _HUD.labelText = @"No available";
        _HUD.detailsLabelText = @"You need to log in to do this.";
        [_HUD show:YES];
        [_HUD hide:YES afterDelay:2];
        return;
    }
    [self.tableView setEditing:YES animated:YES];
    self.navigationItem.rightBarButtonItem = _doneBtn;

}

- (void)editIssueListDone:(id)sender {
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.optionsMenu.barItem;
}
@end
