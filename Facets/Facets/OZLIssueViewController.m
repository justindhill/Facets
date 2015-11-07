//
//  OZLIssueViewController.m
//  Facets
//
//  Created by Justin Hill on 11/5/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLIssueViewController.h"
#import "OZLIssueHeaderView.h"
#import <DRPSlidingTabView/DRPSlidingTabView.h>

const NSInteger OZLDetailSectionIndex = 0;
NSString * const OZLDetailReuseIdentifier = @"OZLDetailReuseIdentifier";

@interface OZLIssueViewController ()

@property (strong) OZLIssueHeaderView *issueHeader;
@property (strong) DRPSlidingTabView *detailView;

@end

@implementation OZLIssueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.issueHeader = [[OZLIssueHeaderView alloc] init];
    self.issueHeader.titleLabel.text = @"Get much better at estimation of tasks and not over-committing on sprint goals";
    self.issueHeader.assigneeDisplayNameLabel.text = @"Justin Hill";
    
    self.detailView = [[DRPSlidingTabView alloc] init];
    self.detailView.tabContainerHeight = 35;
    self.detailView.titleFont = [UIFont systemFontOfSize:14];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:OZLDetailReuseIdentifier];
    
    UIView *aboutView = [[UIView alloc] init];
    aboutView.backgroundColor = [UIColor lightGrayColor];
    [self.detailView addPage:aboutView withTitle:@"ABOUT"];
    
    UIView *scheduleView = [[UIView alloc] init];
    scheduleView.backgroundColor = [UIColor grayColor];
    [self.detailView addPage:scheduleView withTitle:@"SCHEDULE"];
    
    UIView *relatedView = [[UIView alloc] init];
    relatedView.backgroundColor = [UIColor darkGrayColor];
    [self.detailView addPage:relatedView withTitle:@"RELATED"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGSize newSize = [self.issueHeader sizeThatFits:CGSizeMake(self.view.frame.size.width, UIViewNoIntrinsicMetric)];
    self.issueHeader.frame = (CGRect){CGPointZero, newSize};
    
    self.tableView.tableHeaderView = self.issueHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == OZLDetailSectionIndex) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == OZLDetailSectionIndex) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OZLDetailReuseIdentifier forIndexPath:indexPath];
        
        if (!self.detailView.superview) {
            [cell.contentView addSubview:self.detailView];
        }
        
        self.detailView.frame = cell.contentView.bounds;
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == OZLDetailSectionIndex) {
        return 250.;
    }
    
    return 44.;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == OZLDetailSectionIndex && indexPath.row == 0) {
        return NO;
    }
    
    return YES;
}

@end
