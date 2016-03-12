//
//  OZLQueryListViewController.m
//  RedmineMobile
//
//  Created by Justin Hill on 10/15/15.
//  Copyright © 2015 Lee Zhijie. All rights reserved.
//

#import "OZLQueryListViewController.h"
#import "OZLNetwork.h"

@interface OZLQueryListViewController () <UITableViewDelegate, UITableViewDataSource>

@property BOOL isFirstAppearance;
@property NSArray *queries;
@property NSInteger displayedProjectId;
@property OZLLoadingView *loadingView;
@property UITableViewController *tableViewController;

@end

@implementation OZLQueryListViewController

NSString * const OZLQueryReuseIdentifier = @"query";

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    }

    return self;
}

- (UITableView *)tableView {
    return self.tableViewController.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addChildViewController:self.tableViewController];
    [self.view addSubview:self.tableViewController.tableView];
    [self.tableViewController didMoveToParentViewController:self];

    self.loadingView = [[OZLLoadingView alloc] init];
    [self.view addSubview:self.loadingView];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.isFirstAppearance = YES;
    self.displayedProjectId = NSNotFound;
    
    // Do any additional setup after loading the view from its nib.
    self.title = @"Queries";
    
    self.tableViewController.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableViewController.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:OZLQueryReuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL needsRefresh = self.displayedProjectId == NSNotFound || !(self.displayedProjectId == [OZLSingleton sharedInstance].currentProjectID);
    
    if (needsRefresh) {
        self.queries = nil;
        [self.tableView reloadData];
        [self refreshData];
    }
    
    self.isFirstAppearance = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.tableView.frame = self.view.bounds;
    self.loadingView.frame = self.view.bounds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.queries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OZLQueryReuseIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    OZLModelQuery *query = self.queries[indexPath.row];
    cell.textLabel.text = query.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OZLModelQuery *query = self.queries[indexPath.row];
    
    OZLIssueListViewModel *vm = [[OZLIssueListViewModel alloc] init];
    vm.title = query.name;
    vm.projectId = query.projectId;
    vm.queryId = query.queryId;
    
    OZLIssueListViewController *vc = [[OZLIssueListViewController alloc] initWithNibName:@"OZLIssueListViewController" bundle:nil];
    vc.viewModel = vm;
    vc.view.tag = OZLSplitViewController.PrimaryPaneMember;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)refreshData {

    if (!self.queries) {
        self.loadingView.hidden = NO;
        [self.loadingView startLoading];
    } else if (!self.tableViewController.refreshControl.isRefreshing) {
        [self.tableViewController.refreshControl beginRefreshing];
    }
    
    __weak OZLQueryListViewController *weakSelf = self;
    
    NSInteger projectId = [OZLSingleton sharedInstance].currentProjectID;
    
    [[OZLNetwork sharedInstance] getQueryListForProject:projectId params:nil completion:^(NSArray *result, NSError *error) {
        if (error) {
            [weakSelf.loadingView endLoadingWithErrorMessage:@"There was a problem loading the query list. Please check your connection and try again."];
        } else {
            [weakSelf.loadingView endLoadingWithErrorMessage:(result.count > 0) ? nil : @"Nothing to see here."];
            weakSelf.displayedProjectId = projectId;
            weakSelf.queries = result;
        }

        weakSelf.loadingView.hidden = (!error && weakSelf.queries.count > 0);
        [weakSelf.tableView reloadData];
        [weakSelf.tableViewController.refreshControl endRefreshing];
    }];
}

@end
