//
//  OZLIssueViewController.m
//  Facets
//
//  Created by Justin Hill on 11/5/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLIssueViewController.h"
#import "OZLIssueHeaderView.h"
#import "OZLIssueDescriptionCell.h"
#import <DRPSlidingTabView/DRPSlidingTabView.h>

#import "OZLIssueAboutTabView.h"
#import "OZLTabTestView.h"

const CGFloat contentPadding = 16;

const NSInteger OZLDetailSectionIndex = 0;
const NSInteger OZLDescriptionSectionIndex = 1;

NSString * const OZLDetailReuseIdentifier = @"OZLDetailReuseIdentifier";
NSString * const OZLDescriptionReuseIdentifier = @"OZLDescriptionReuseIdentifier";

@interface OZLIssueViewController () <DRPSlidingTabViewDelegate>

@property (strong) OZLIssueHeaderView *issueHeader;
@property (strong) DRPSlidingTabView *detailView;
@property (strong) OZLIssueAboutTabView *aboutTabView;

@property BOOL isFirstAppearance;

@end

@implementation OZLIssueViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.issueHeader = [[OZLIssueHeaderView alloc] init];
    self.issueHeader.contentPadding = contentPadding;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:OZLDetailReuseIdentifier];
    [self.tableView registerClass:[OZLIssueDescriptionCell class] forCellReuseIdentifier:OZLDescriptionReuseIdentifier];
    
    self.isFirstAppearance = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isFirstAppearance) {
        self.detailView = [[DRPSlidingTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        self.detailView.delegate = self;
        self.detailView.tabContainerHeight = 35;
        self.detailView.titleFont = [UIFont systemFontOfSize:14];
        self.detailView.backgroundColor = [UIColor OZLVeryLightGrayColor];
        self.detailView.dividerColor = [UIColor OZLVeryLightGrayColor];
        self.detailView.sliderHeight = 3.;
        
        self.aboutTabView = [[OZLIssueAboutTabView alloc] init];
        self.aboutTabView.backgroundColor = [UIColor OZLVeryLightGrayColor];
        self.aboutTabView.contentPadding = contentPadding;
        [self.detailView addPage:self.aboutTabView withTitle:@"ABOUT"];
        
        OZLTabTestView *scheduleView = [[OZLTabTestView alloc] init];
        scheduleView.backgroundColor = [UIColor OZLVeryLightGrayColor];
        scheduleView.heightToReport = 100;
        [self.detailView addPage:scheduleView withTitle:@"SCHEDULE"];
        
        OZLTabTestView *relatedView = [[OZLTabTestView alloc] init];
        relatedView.backgroundColor = [UIColor OZLVeryLightGrayColor];
        relatedView.heightToReport = 200;
        [self.detailView addPage:relatedView withTitle:@"RELATED"];
    }
    
    if (self.issueModel) {
        [self applyIssueModel:self.issueModel];
    }
    
    self.isFirstAppearance = NO;
}

#pragma mark - Accessors
- (void)setIssueModel:(OZLModelIssue *)issueModel {
    _issueModel = issueModel;
    
    if (self.isViewLoaded) {
        [self applyIssueModel:issueModel];
    }
}

- (void)applyIssueModel:(OZLModelIssue *)issue {
    self.navigationItem.title = issue.tracker.name;
    [self.issueHeader applyIssueModel:issue];
    [self.aboutTabView applyIssueModel:issue];
    [self refreshHeaderSize];
    
    [self.tableView reloadData];
}

- (void)refreshHeaderSize {
    CGSize newSize = [self.issueHeader sizeThatFits:CGSizeMake(self.view.frame.size.width, UIViewNoIntrinsicMetric)];
    self.issueHeader.frame = (CGRect){CGPointZero, newSize};
    self.tableView.tableHeaderView = self.issueHeader;
}

#pragma mark - UITableViewDelegate / DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == OZLDetailSectionIndex) {
        return 1;
    } else if (section == OZLDescriptionSectionIndex) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == OZLDetailSectionIndex) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OZLDetailReuseIdentifier forIndexPath:indexPath];
        cell.clipsToBounds = YES;
        self.detailView.frame = cell.contentView.bounds;
        
        if (!self.detailView.superview) {
            [cell.contentView addSubview:self.detailView];
        }
        
        
        return cell;
        
    } else if (indexPath.section == OZLDescriptionSectionIndex) {
        OZLIssueDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:OZLDescriptionReuseIdentifier forIndexPath:indexPath];
        cell.contentPadding = 16.;
        cell.descriptionPreviewString = self.issueModel.description;
        
        return cell;
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == OZLDetailSectionIndex) {
        return self.detailView.intrinsicHeight;
        
    } else if (indexPath.section == OZLDescriptionSectionIndex) {

        return [OZLIssueDescriptionCell heightForWidth:tableView.frame.size.width
                                           description:self.issueModel.description
                                        contentPadding:contentPadding];
    };
    
    return 44.;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - DRPSlidingTabViewDelegate
- (void)view:(UIView *)view intrinsicHeightDidChangeTo:(CGFloat)newHeight {
    if (view == self.detailView) {
        [UIView beginAnimations:nil context:NULL];
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        self.detailView.frame = self.detailView.superview.bounds;
        
        [UIView commitAnimations];
    }
}

@end
