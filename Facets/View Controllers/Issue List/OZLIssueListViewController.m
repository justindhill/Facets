//
//  OZLIssueListViewController.m
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/14/13.

#import "OZLIssueListViewController.h"
#import "OZLNetwork.h"
#import "MBProgressHUD.h"
#import "OZLIssueViewController.h"
#import "OZLSingleton.h"
#import "OZLLoadingView.h"
#import "OZLNavigationChildChangeListener.h"

#import "Facets-Swift.h"

const CGFloat OZLIssueListComposeButtonHeight = 48.;
const NSInteger OZLZeroHeightFooterTag = -1;

@interface OZLIssueListViewController () <UIViewControllerPreviewingDelegate, OZLNavigationChildChangeListener, OZLSortAndFilterViewControllerDelegate> {

    float _sideviewOffset;
    MBProgressHUD  *_HUD;
    UIBarButtonItem *_editBtn;
    UIBarButtonItem *_doneBtn;
}

@property BOOL isFirstAppearance;
@property UIButton *composeButton;

@end

@implementation OZLIssueListViewController

#pragma mark - Life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.isFirstAppearance = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    _doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editIssueListDone:)];

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:_HUD];
	_HUD.labelText = @"Loading...";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.viewModel.projectId = [OZLSingleton sharedInstance].currentProjectID;
    self.title = self.viewModel.title;
    
    if (self.isFirstAppearance) {
        [self refreshProjectSelector];
        self.view.tintColor = self.parentViewController.view.tintColor;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-filter"] style:UIBarButtonItemStyleDone target:self action:@selector(filterAction:)];
        
        [self showFooterActivityIndicator];
        [self reloadProjectData];
    }
    
    if (self.viewModel.shouldShowComposeButton && !self.composeButton.superview) {
        self.composeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.composeButton.backgroundColor = self.view.tintColor;
        self.composeButton.tintColor = [UIColor whiteColor];
        [self.composeButton setImage:[UIImage ozl_templateImageNamed:@"icon-plus"] forState:UIControlStateNormal];
        [self.composeButton.titleLabel setFont:[UIFont systemFontOfSize:28]];
        self.composeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.composeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        self.composeButton.layer.shadowColor = [UIColor blackColor].CGColor;
        self.composeButton.layer.shadowOpacity = .2;
        self.composeButton.layer.shadowOffset = CGSizeMake(0, 2.);
        
        self.composeButton.frame = CGRectMake(0, 0, OZLIssueListComposeButtonHeight, OZLIssueListComposeButtonHeight);
        self.composeButton.layer.cornerRadius = 24.;
        [self.composeButton addTarget:self action:@selector(composeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.composeButton];
        
    } else if (!self.viewModel.shouldShowComposeButton && self.composeButton.superview) {
        [self.composeButton removeFromSuperview];
        self.composeButton = nil;
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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (self.composeButton) {
        CGPoint newOrigin = CGPointMake(self.view.frame.size.width - OZLContentPadding - self.composeButton.frame.size.width,
                                        self.view.frame.size.height - OZLContentPadding - self.composeButton.frame.size.height - self.bottomLayoutGuide.length);
        
        self.composeButton.frame = (CGRect){newOrigin, self.composeButton.frame.size};
    }
}

- (void)setViewModel:(OZLIssueListViewModel *)viewModel {
    _viewModel = viewModel;
    viewModel.delegate = self;
}

#pragma mark - Behavior
- (void)refreshProjectSelector {
    if (self.viewModel.shouldShowProjectSelector) {
        
        NSMutableArray *titlesArray = [NSMutableArray arrayWithCapacity:self.viewModel.projects.count];
        
        for (OZLModelProject *project in self.viewModel.projects) {
            [titlesArray addObject:project.name];
        }
        
        // BTNavigationDropdownMenu must be initialized with its items, so we have to re-initialize it every time we want to
        // change the items. Blech.
        BTNavigationDropdownMenu *dropdown = [[BTNavigationDropdownMenu alloc] initWithNavigationController:self.navigationController title:self.viewModel.title items:titlesArray];
        dropdown.cellTextLabelFont = [UIFont OZLMediumSystemFontOfSize:17];
        
        // use the parent view controller's tint color. BTNavigationDropdownMenu doesn't properly
        // respond to tintColorDidChange, so using this view's tint color won't do any good, as
        // we're not added to the window yet.
        dropdown.tintColor = self.parentViewController.view.tintColor;
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

- (void)reloadProjectData {

    __weak OZLIssueListViewController *weakSelf = self;
    [self.viewModel loadIssuesCompletion:^(NSError *error) {
        
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Couldn't load issue list" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            [weakSelf presentViewController:alert animated:NO completion:nil];
            
        } else {
            [weakSelf.tableView reloadData];
            
            if (!weakSelf.viewModel.moreIssuesAvailable) {
                [weakSelf hideFooterActivityIndicator];
            }
        }
    }];
}

- (void)showProjectList {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Actions
- (void)refreshAction:(UIRefreshControl *)refreshControl {
    [self reloadProjectData];
}

- (void)filterAction:(UIButton *)button {
    OZLSortAndFilterViewController *sortAndFilter = [[OZLSortAndFilterViewController alloc] initWithStyle:UITableViewStyleGrouped];
    sortAndFilter.delegate = self;
    sortAndFilter.options = self.viewModel.sortAndFilterOptions;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sortAndFilter];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)composeButtonAction:(UIButton *)button {
    OZLIssueComposerViewController *composer = [[OZLIssueComposerViewController alloc] init];
    composer.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissComposerAction:)];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composer];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)dismissComposerAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Project selector
- (void)didSelectProjectAtIndex:(NSInteger)index {
    OZLModelProject *project = self.viewModel.projects[index];
    
    if (self.viewModel.projectId == project.projectId) {
        return;
    }
    
    [self showFooterActivityIndicator];
    [OZLSingleton sharedInstance].currentProjectID = project.projectId;
    self.viewModel.projectId = project.projectId;
    [self.tableView reloadData];
    [self reloadProjectData];
}

#pragma mark - OZLSortAndFilterViewControllerDelegate
- (void)sortAndFilter:(OZLSortAndFilterViewController *)sortAndFilter shouldDismissWithNewOptions:(OZLSortAndFilterOptions *)newOptions {
    if (newOptions && ![newOptions isEqual:self.viewModel.sortAndFilterOptions]) {
        self.viewModel.sortAndFilterOptions = newOptions;
        [self.tableView reloadData];
        [self showFooterActivityIndicator];
        [self reloadProjectData];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Previewing
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    CGPoint translatedLocation = CGPointMake(location.x, self.tableView.contentOffset.y + location.y);
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:translatedLocation];
    
    OZLModelIssue *issueModel = self.viewModel.issues[indexPath.row];
    OZLIssueViewModel *viewModel = [[OZLIssueViewModel alloc] initWithIssueModel:issueModel];
    
    OZLIssueViewController *issueVC = [[OZLIssueViewController alloc] init];
    issueVC.viewModel = viewModel;
    issueVC.previewQuickAssignDelegate = self.viewModel;
    
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
    cell.detailTextLabel.text = issue.assignedTo.name;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//
//        _HUD.labelText = @"Deleting Issue...";
//        _HUD.detailsLabelText = @"";
//        _HUD.mode = MBProgressHUDModeIndeterminate;
//        [_HUD show:YES];
//        [self.viewModel deleteIssueAtIndex:indexPath.row completion:^(NSError *error) {
//            if (error) {
//                NSLog(@"failed to delete issue");
//                _HUD.mode = MBProgressHUDModeText;
//                _HUD.labelText = @"Connection Failed";
//                _HUD.detailsLabelText = @" Please check network connection or your account setting.";
//                [_HUD hide:YES afterDelay:3];
//                
//            } else {
//                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                [_HUD hide:YES];
//            }
//        }];
//    }
//}

- (void)showFooterActivityIndicator {
    if (self.tableView.tableFooterView && self.tableView.tableFooterView.tag != OZLZeroHeightFooterTag) {
        return;
    }
    
    CGFloat height = (OZLContentPadding * 2) + OZLIssueListComposeButtonHeight;
    
    OZLLoadingView *loadingView = [[OZLLoadingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    [loadingView.loadingSpinner startAnimating];
    self.tableView.tableFooterView = loadingView;
}

- (void)hideFooterActivityIndicator {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.tableFooterView.tag = OZLZeroHeightFooterTag;
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
    
    [self.splitViewController showViewController:issueVC sender:self];
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

#pragma mark - View model delegate
- (void)viewModelIssueListContentDidChange:(OZLIssueListViewModel *)viewModel {
    [self.tableView reloadData];
}

#pragma mark - OZLNavigationChildChangeListener
- (void)navigationChild:(UIViewController *)navigationChild didModifyIssue:(OZLModelIssue *)issue {
    [self.viewModel processUpdatedIssue:issue];
}

@end
