//
//  OZLIssueListViewController.m
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/14/13.

#import "OZLIssueListViewController.h"
#import "OZLProjectListViewController.h"
#import "OZLNetwork.h"
#import "MBProgressHUD.h"
#import "OZLProjectInfoViewController.h"
#import "OZLIssueViewController.h"
#import "OZLSingleton.h"
#import "OZLLoadingView.h"

#import "Facets-Swift.h"

@interface OZLIssueListViewController () <UIViewControllerPreviewingDelegate> {

    float _sideviewOffset;
    MBProgressHUD  *_HUD;
    UIBarButtonItem *_editBtn;
    UIBarButtonItem *_doneBtn;
}

@property BOOL isFirstAppearance;
@property CAPSOptionsMenu *optionsMenu;

@end

@implementation OZLIssueListViewController

#pragma mark - Life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.isFirstAppearance = YES;
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}

- (void)viewDidLoad {
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
        [self.optionsMenu addAction:[[CAPSOptionsMenuAction alloc] initWithTitle:@"Edit" handler:^(CAPSOptionsMenuAction *_Nonnull action) {
            [weakSelf editIssueList:nil];
        }]];
        
        [self.optionsMenu addAction:[[CAPSOptionsMenuAction alloc] initWithTitle:@"Sort" handler:^(CAPSOptionsMenuAction *_Nonnull action) {
        }]];
        
        [self.optionsMenu addAction:[[CAPSOptionsMenuAction alloc] initWithTitle:@"Copy Link" handler:^(CAPSOptionsMenuAction *_Nonnull action) {
        }]];
        
        self.view.tintColor = self.parentViewController.view.tintColor;
        [self refreshProjectSelector];
        
        [self showFooterActivityIndicator];
        [self reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Check for force touch feature, and add force touch/previewing capability.
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            [self registerForPreviewingWithDelegate:self sourceView:self.view];
        }
    }
    
    if (!self.isFirstAppearance) {
        [self refreshProjectSelector];
    }
    
    self.isFirstAppearance = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Behavior
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
        dropdown.tintColor = self.view.tintColor;
        dropdown.cellBackgroundColor = [UIColor colorWithRed:(249. / 255.) green:(249. / 255.) blue:(249. / 255.) alpha:1.];
        dropdown.cellSeparatorColor = [UIColor lightGrayColor];
        dropdown.cellTextLabelColor = [UIColor darkGrayColor];
        dropdown.cellSelectionColor = [UIColor OZLVeryLightGrayColor];
        dropdown.arrowImage = [dropdown.arrowImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        dropdown.checkMarkImage = nil;
        
        __weak OZLIssueListViewController *weakSelf = self;
        dropdown.didSelectItemAtIndexHandler = ^(NSInteger index) {
            [weakSelf didSelectProjectAtIndex:index];
        };
        
        self.navigationItem.titleView = dropdown;
    }
}

- (void)reloadData {

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
    
    if (self.viewModel.projectId == project.index) {
        return;
    }
    
    [self showFooterActivityIndicator];
    self.viewModel.projectId = project.index;
    [self.tableView reloadData];
    
    __weak OZLIssueListViewController *weakSelf = self;
    [self.viewModel loadIssuesSortedBy:nil ascending:NO completion:^(NSError *error) {
        
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
    
    OZLModelIssue *issueModel = self.viewModel.issues[indexPath.row];
    OZLIssueViewModel *viewModel = [[OZLIssueViewModel alloc] initWithIssueModel:issueModel];
    
    OZLIssueViewController *issueVC = [[OZLIssueViewController alloc] init];
    issueVC.viewModel = viewModel;
    
    return issueVC;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellidentifier];
    }
    
    OZLModelIssue *issue = self.viewModel.issues[indexPath.row];
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

- (void)showFooterActivityIndicator {
    if (self.tableView.tableFooterView) {
        return;
    }
    
    OZLLoadingView *loadingView = [[OZLLoadingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [loadingView.loadingSpinner startAnimating];
    self.tableView.tableFooterView = loadingView;
}

- (void)hideFooterActivityIndicator {
    self.tableView.tableFooterView = nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat distanceFromBottom = scrollView.contentSize.height -
                                 scrollView.contentOffset.y -
                                 scrollView.frame.size.height;
    
    if (self.viewModel.isLoading) {
        return;
    }
    
    __weak OZLIssueListViewController *weakSelf = self;
    
    if (self.viewModel.moreIssuesAvailable && distanceFromBottom <= 44. &&
        self.tableView.contentSize.height > self.tableView.frame.size.height) {
        [self.viewModel loadMoreIssuesCompletion:^(NSError *error) {
            [weakSelf.tableView reloadData];
            
            if (!weakSelf.viewModel.moreIssuesAvailable) {
                [weakSelf hideFooterActivityIndicator];
            }
        }];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OZLModelIssue *issueModel = self.viewModel.issues[indexPath.row];
    OZLIssueViewModel *viewModel = [[OZLIssueViewModel alloc] initWithIssueModel:issueModel];
    
    OZLIssueViewController *issueVC = [[OZLIssueViewController alloc] init];
    issueVC.viewModel = viewModel;
    
    [self.navigationController pushViewController:issueVC animated:YES];
}

- (IBAction)onShowInfo:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OZLProjectInfoViewController" bundle:nil];
    OZLProjectInfoViewController *detail = [storyboard instantiateViewControllerWithIdentifier:@"OZLProjectInfoViewController"];
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
