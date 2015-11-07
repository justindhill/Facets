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

const CGFloat contentPadding = 16;

const NSInteger OZLDetailSectionIndex = 0;
const NSInteger OZLDescriptionSectionIndex = 1;

NSString * const OZLDetailReuseIdentifier = @"OZLDetailReuseIdentifier";
NSString * const OZLDescriptionReuseIdentifier = @"OZLDescriptionReuseIdentifier";

@interface OZLIssueViewController ()

@property (strong) OZLIssueHeaderView *issueHeader;
@property (strong) DRPSlidingTabView *detailView;

@end

@implementation OZLIssueViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.issueHeader = [[OZLIssueHeaderView alloc] init];
    self.issueHeader.contentPadding = contentPadding;
    
    self.detailView = [[DRPSlidingTabView alloc] init];
    self.detailView.tabContainerHeight = 35;
    self.detailView.titleFont = [UIFont systemFontOfSize:14];
    self.detailView.contentBackgroundColor = [UIColor OZLVeryLightGrayColor];
    self.detailView.dividerColor = [UIColor OZLVeryLightGrayColor];
    self.detailView.sliderHeight = 3.;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:OZLDetailReuseIdentifier];
    [self.tableView registerClass:[OZLIssueDescriptionCell class] forCellReuseIdentifier:OZLDescriptionReuseIdentifier];
    
    UIView *aboutView = [[UIView alloc] init];
    aboutView.backgroundColor = [UIColor OZLVeryLightGrayColor];
    [self.detailView addPage:aboutView withTitle:@"ABOUT"];
    
    UIView *scheduleView = [[UIView alloc] init];
    scheduleView.backgroundColor = [UIColor OZLVeryLightGrayColor];
    [self.detailView addPage:scheduleView withTitle:@"SCHEDULE"];
    
    UIView *relatedView = [[UIView alloc] init];
    relatedView.backgroundColor = [UIColor OZLVeryLightGrayColor];
    [self.detailView addPage:relatedView withTitle:@"RELATED"];
    
    if (self.issueModel) {
        [self.issueHeader applyIssueModel:self.issueModel];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshHeaderSize];
}

#pragma mark - Accessors
- (void)setIssueModel:(OZLModelIssue *)issueModel {
    _issueModel = issueModel;
    
    if (self.isViewLoaded) {
        [self applyIssueModel:issueModel];
    }
}

- (void)applyIssueModel:(OZLModelIssue *)issue {
    [self.issueHeader applyIssueModel:issue];
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
        
        if (!self.detailView.superview) {
            [cell.contentView addSubview:self.detailView];
        }
        
        self.detailView.frame = cell.contentView.bounds;
        
        return cell;
        
    } else if (indexPath.section == OZLDescriptionSectionIndex) {
        OZLIssueDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:OZLDescriptionReuseIdentifier forIndexPath:indexPath];
        cell.contentPadding = 16.;
        cell.descriptionPreviewLabel.text = self.issueModel.description;
        
        return cell;
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == OZLDetailSectionIndex) {
        return 250.;
        
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

@end
