//
//  OZLIssueListViewController.m
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

#import "OZLIssueListViewController.h"
#import "OZLProjectListViewController.h"
#import "OZLNetwork.h"
#import "MBProgressHUD.h"
#import "OZLProjectInfoViewController.h"
#import "OZLIssueDetailViewController.h"
#import "OZLIssueCreateOrUpdateViewController.h"
#import "OZLIssueFilterViewController.h"
#import "OZLSingleton.h"

#import "Facets-Swift.h"

@interface OZLIssueListViewController () <UIViewControllerPreviewingDelegate> {

    float _sideviewOffset;
    MBProgressHUD * _HUD;
    UIBarButtonItem* _editBtn;
    UIBarButtonItem* _doneBtn;
}

@property BOOL isFirstAppearance;
@property CAPSOptionsMenu *optionsMenu;

@end

@implementation OZLIssueListViewController

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.viewModel.projectId = [OZLSingleton sharedInstance].currentProjectID;
    
    if (self.isFirstAppearance) {
        self.optionsMenu = [[CAPSOptionsMenu alloc] initWithViewController:self barButtonSystemItem:UIBarButtonSystemItemAction keepBarButtonAtEdge:NO];
    
        __weak OZLIssueListViewController *weakSelf = self;
        [self.optionsMenu addAction:[[CAPSOptionsMenuAction alloc] initWithTitle:@"Edit" handler:^(CAPSOptionsMenuAction * _Nonnull action) {
            [weakSelf editIssueList:nil];
        }]];
        
        [self.optionsMenu addAction:[[CAPSOptionsMenuAction alloc] initWithTitle:@"Sort" handler:^(CAPSOptionsMenuAction * _Nonnull action) {
        }]];
        
        [self.optionsMenu addAction:[[CAPSOptionsMenuAction alloc] initWithTitle:@"Copy Link" handler:^(CAPSOptionsMenuAction * _Nonnull action) {
        }]];
        
        [self refreshProjectSelector];
    }
    
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Check for force touch feature, and add force touch/previewing capability.
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
    
    if (!self.isFirstAppearance) {
        [self refreshProjectSelector];
    }
    
    self.isFirstAppearance = NO;
}


- (void)refreshProjectSelector {
    if (self.viewModel.shouldShowProjectSelector) {
        //        NSAssert([self.viewModel respondsToSelector:@selector(refreshProjectList)], @"View model states we should show project selector, but refreshProjectList isn't implemented");
        [self.viewModel refreshProjectList];
        
        NSMutableArray *titlesArray = [NSMutableArray arrayWithCapacity:self.viewModel.projects.count];
        for (OZLModelProject *project in self.viewModel.projects) {
            [titlesArray addObject:project.name];
        }
        
        // BTNavigationDropdownMenu must be initialized with its items, so we have to re-initialize it every time we want to
        // change the items. Blech.
        BTNavigationDropdownMenu *dropdown = [[BTNavigationDropdownMenu alloc] initWithTitle:self.viewModel.title items:titlesArray];
        dropdown.cellTextLabelFont = [UIFont OZLMediumSystemFontOfSize:17];
        
        __weak OZLIssueListViewController *weakSelf = self;
        dropdown.didSelectItemAtIndexHandler = ^(NSInteger index) {
            [weakSelf didSelectProjectAtIndex:index];
        };
        
        self.navigationItem.titleView = dropdown;
    }
}

- (void)reloadData
{
    if (!self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }

    __weak OZLIssueListViewController *weakSelf = self;
    [self.viewModel loadIssuesSortedBy:nil ascending:NO completion:^(NSError *error) {
        [weakSelf.tableView reloadData];
        [weakSelf.refreshControl endRefreshing];
    }];
}

- (void)showProjectList {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Actions
- (void)refreshAction:(UIRefreshControl *)refreshControl {
    [self reloadData];
}

#pragma mark - Project selector
- (void)didSelectProjectAtIndex:(NSInteger)index {
    OZLModelProject *project = self.viewModel.projects[index];
    
    self.viewModel.projectId = project.index;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.animationType = MBProgressHUDAnimationZoom;
    
    __weak OZLIssueListViewController *weakSelf = self;
    [self.viewModel loadIssuesSortedBy:nil ascending:NO completion:^(NSError *error) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Couldn't load issue list" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            [weakSelf presentViewController:alert animated:NO completion:nil];
            
        } else {
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark - Previewing
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    UIStoryboard *tableViewStoryboard = [UIStoryboard storyboardWithName:@"OZLIssueDetailViewController" bundle:nil];
    OZLIssueDetailViewController* detail = [tableViewStoryboard instantiateViewControllerWithIdentifier:@"OZLIssueDetailViewController"];
    
    OZLModelIssue *issue = self.viewModel.issues[indexPath.row];
    [detail setIssueData:issue];
    
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
    return self.viewModel.issues.count;
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
    
    OZLModelIssue* issue = self.viewModel.issues[indexPath.row];
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
        [self.viewModel deleteIssueAtIndex:indexPath.row completion:^(NSError *error) {
            if (error) {
                NSLog(@"failed to delete issue");
                _HUD.mode = MBProgressHUDModeText;
                _HUD.labelText = @"Connection Failed";
                _HUD.detailsLabelText = @" Please check network connection or your account setting.";
                [_HUD hide:YES afterDelay:3];
                
            } else {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [_HUD hide:YES];
            }
        }];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //OZLIssueDetailViewController* detail = [[OZLIssueDetailViewController alloc] initWithNibName:@"OZLIssueDetailViewController" bundle:nil];
    UIStoryboard *tableViewStoryboard = [UIStoryboard storyboardWithName:@"OZLIssueDetailViewController" bundle:nil];
    
    OZLModelIssue *issue = self.viewModel.issues[indexPath.row];
    
    OZLIssueDetailViewController* detail = [tableViewStoryboard instantiateViewControllerWithIdentifier:@"OZLIssueDetailViewController"];
    [detail setIssueData:issue];
    [self.navigationController pushViewController:detail animated:YES];
}

- (IBAction)onNewIssue:(id)sender {
    if (![OZLSingleton sharedInstance].isUserLoggedIn ) {
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
    if (![OZLSingleton sharedInstance].isUserLoggedIn) {
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
