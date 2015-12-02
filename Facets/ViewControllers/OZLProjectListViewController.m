//
//  OZLProjectListViewController.m
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/14/13.

#import "OZLProjectListViewController.h"
#import "OZLIssueListViewController.h"
#import "OZLAccountViewController.h"
#import "OZLProjectInfoViewController.h"
#import "OZLNetwork.h"
#import "OZLModelProject.h"
#import "MBProgressHUD.h"
#import "OZLSingleton.h"
#import "OZLProjectIssueListViewModel.h"

@interface OZLProjectListViewController (){
    RLMResults<OZLModelProject *> *_projectList;
	MBProgressHUD *_HUD;

    UIBarButtonItem *_editBtn;
    UIBarButtonItem *_doneBtn;
}

@end

@implementation OZLProjectListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _projectsTableview.delegate = self;
    _projectsTableview.dataSource = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _projectsTableview.backgroundColor = [UIColor whiteColor];

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:_HUD];

    _editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editProjectList:)];
    _doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editProjectListDone:)];
    [self.navigationItem setRightBarButtonItem:_editBtn];
    [self.navigationItem setTitle:@"Projects"];
    
    _projectList = [[OZLModelProject allObjects] sortedResultsUsingProperty:@"name" ascending:YES];
}

- (void)showProjectView:(OZLModelProject *)project {
    OZLProjectIssueListViewModel *viewModel = [[OZLProjectIssueListViewModel alloc] init];
    viewModel.title = project.name;
    viewModel.projectId = project.index;
    
    OZLIssueListViewController *c = [[OZLIssueListViewController alloc] initWithNibName:@"OZLIssueListViewController" bundle:nil];
    c.viewModel = viewModel;

    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)showAccountView:(id)sender {
    OZLAccountViewController *c = [[OZLAccountViewController alloc] initWithNibName:@"OZLAccountViewController" bundle:nil];

    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:c animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                     }];
}

- (void)editProjectList:(id)sender {
    
    if (![OZLSingleton sharedInstance].isUserLoggedIn ) {
        _HUD.mode = MBProgressHUDModeText;
        _HUD.labelText = @"No available";
        _HUD.detailsLabelText = @"You need to log in to do this.";
        [_HUD show:YES];
        [_HUD hide:YES afterDelay:2];
        return;
    }
    [_projectsTableview setEditing:YES animated:YES];
    self.navigationItem.rightBarButtonItem = _doneBtn;
    
}

- (void)editProjectListDone:(id)sender {
    [_projectsTableview setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = _editBtn;
}

- (void)viewDidUnload {
    [self setProjectsTableview:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return [_projectList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellidentifier = [NSString stringWithFormat:@"project_cell_id"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellidentifier];
    }
    
    OZLModelProject *project = [_projectList objectAtIndex:indexPath.row];
    cell.textLabel.text = project.name;
    cell.detailTextLabel.text = project.description;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showProjectView:[_projectList objectAtIndex:indexPath.row]];
}

@end