//
//  OZLIssueViewController.m
//  Facets
//
//  Created by Justin Hill on 11/5/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import DRPSlidingTabView;
@import AVKit;
@import AVFoundation;
@import JTSImageViewController;
@import TTTAttributedLabel;

#import "OZLIssueViewController.h"
#import "OZLIssueHeaderView.h"
#import "OZLIssueDescriptionCell.h"
#import "OZLIssueFullDescriptionViewController.h"
#import "OZLWebViewController.h"
#import "OZLLoadingView.h"

#import "OZLIssueAboutTabView.h"
#import "OZLTabTestView.h"
#import "OZLIssueAttachmentGalleryCell.h"
#import "OZLNavigationChildChangeListener.h"
#import "Facets-Swift.h"

NSString * const OZLDetailReuseIdentifier = @"OZLDetailReuseIdentifier";
NSString * const OZLDescriptionReuseIdentifier = @"OZLDescriptionReuseIdentifier";
NSString * const OZLAttachmentsReuseIdentifier = @"OZLAttachmentsReuseIdentifier";
NSString * const OZLRecentActivityReuseIdentifier = @"OZLRecentActivityReuseIdentifier";

@interface OZLIssueViewController () <OZLIssueViewModelDelegate, DRPSlidingTabViewDelegate, OZLIssueAttachmentGalleryCellDelegate, AVAssetResourceLoaderDelegate, UIViewControllerTransitioningDelegate>

@property (strong) OZLIssueHeaderView *issueHeader;
@property (strong) DRPSlidingTabView *detailView;
@property (strong) OZLIssueAboutTabView *aboutTabView;

@property BOOL isFirstAppearance;

@end

@implementation OZLIssueViewController

#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.issueHeader = [[OZLIssueHeaderView alloc] init];
    self.issueHeader.contentPadding = OZLContentPadding;
    [self.issueHeader.assignButton addTarget:self action:@selector(quickAssignAction:) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction:)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:OZLDetailReuseIdentifier];
    [self.tableView registerClass:[OZLIssueDescriptionCell class] forCellReuseIdentifier:OZLDescriptionReuseIdentifier];
    [self.tableView registerClass:[OZLIssueAttachmentGalleryCell class] forCellReuseIdentifier:OZLAttachmentsReuseIdentifier];
    [self.tableView registerClass:[OZLJournalCell class] forCellReuseIdentifier:OZLRecentActivityReuseIdentifier];
    
    self.isFirstAppearance = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSAssert(self.viewModel.issueModel, @"Attempted to show an issue view controller with no issue.");
    
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
        self.aboutTabView.contentPadding = OZLContentPadding;
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
    
    if (self.viewModel.issueModel) {
        [self applyIssueModel:self.viewModel.issueModel];
    }
    
    self.isFirstAppearance = NO;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.tableView beginUpdates];
        [self refreshHeaderSizeForWidth:size.width];
        [self.tableView endUpdates];
    } completion:nil];
}

#pragma mark - Accessors
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)setViewModel:(OZLIssueViewModel *)viewModel {
    
    _viewModel = viewModel;
    viewModel.delegate = self;
    
    if (self.isViewLoaded && viewModel.issueModel) {
        [self applyIssueModel:viewModel.issueModel];
    }
}

- (void)applyIssueModel:(OZLModelIssue *)issue {
    self.navigationItem.title = [NSString stringWithFormat:@"%@ #%ld", issue.tracker.name, (long)issue.index];
    [self.issueHeader applyIssueModel:issue];
    [self.aboutTabView applyIssueModel:issue];
    [self refreshHeaderSizeForWidth:self.view.frame.size.width];
    
    if (self.viewModel.completeness == OZLIssueCompletenessSome) {
        [self showLoadingSpinner];
        [self.viewModel loadIssueData];
    }
    
    [self.tableView reloadData];
}

- (void)refreshHeaderSizeForWidth:(CGFloat)width {
    CGSize newSize = [self.issueHeader sizeThatFits:CGSizeMake(width, UIViewNoIntrinsicMetric)];
    self.issueHeader.frame = (CGRect){CGPointZero, newSize};
    self.tableView.tableHeaderView = self.issueHeader;
}

- (void)showLoadingSpinner {
    if (!self.tableView.tableFooterView) {
        OZLLoadingView *loadingView = [[OZLLoadingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        self.tableView.tableFooterView = loadingView;
        
        [loadingView startLoading];
    }
}

- (void)hideLoadingSpinner {
    if (self.tableView.tableFooterView) {
        self.tableView.tableFooterView = nil;
    }
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    NSMutableArray *items = [NSMutableArray array];
    
    [items addObject:[UIPreviewAction actionWithTitle:@"Quick Assign" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        OZLQuickAssignViewController *vc = [[OZLQuickAssignViewController alloc] initWithIssueModel:[self.viewModel.issueModel copy]];
        vc.transitioningDelegate = self;
        vc.modalPresentationStyle = UIModalPresentationCustom;
        vc.delegate = self.previewQuickAssignDelegate;
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:vc animated:YES completion:nil];
    }]];

    [items addObject:[UIPreviewAction actionWithTitle:@"Edit" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        OZLIssueComposerViewController *vc = [[OZLIssueComposerViewController alloc] initWithIssue:self.viewModel.issueModel];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];

        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:nav animated:YES completion:nil];
    }]];
    
    return items;
}

#pragma mark - Button actions
- (void)editButtonAction:(UIButton *)button {
    OZLIssueComposerViewController *vc = [[OZLIssueComposerViewController alloc] initWithIssue:self.viewModel.issueModel];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.barTintColor = [UIColor whiteColor];

    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showFullDescriptionAction:(UIButton *)button {
    OZLIssueFullDescriptionViewController *descriptionVC = [[OZLIssueFullDescriptionViewController alloc] init];
    descriptionVC.descriptionLabel.text = self.viewModel.issueModel.description;
    descriptionVC.contentPadding = OZLContentPadding;
    
    [self.navigationController pushViewController:descriptionVC animated:YES];
}

- (void)showAllActivityAction:(UIButton *)button {
    OZLJournalViewerViewModel *vm = [[OZLJournalViewerViewModel alloc] initWithIssue:self.viewModel.issueModel];
    OZLJournalViewerViewController *vc = [[OZLJournalViewerViewController alloc] initWithViewModel:vm];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)quickAssignAction:(UIButton *)button {
    
    OZLQuickAssignViewController *vc = [[OZLQuickAssignViewController alloc] initWithIssueModel:[self.viewModel.issueModel copy]];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self;
    vc.delegate = self.viewModel;
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate / DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionName = self.viewModel.currentSectionNames[section];
    
    if ([sectionName isEqualToString:OZLIssueSectionRecentActivity]) {
        return self.viewModel.recentActivityCount;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionName = self.viewModel.currentSectionNames[indexPath.section];
    
    if ([sectionName isEqualToString:OZLIssueSectionDetail]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OZLDetailReuseIdentifier forIndexPath:indexPath];
        cell.clipsToBounds = YES;
        
        if (!self.detailView.superview) {
            [cell.contentView addSubview:self.detailView];
            
            self.detailView.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        }
        
        return cell;
        
    } else if ([sectionName isEqualToString:OZLIssueSectionDescription]) {
        OZLIssueDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:OZLDescriptionReuseIdentifier forIndexPath:indexPath];
        cell.contentPadding = 16.;
        cell.descriptionPreviewString = self.viewModel.issueModel.description;
        [cell.showMoreButton addTarget:self action:@selector(descriptionShowMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    } else if ([sectionName isEqualToString:OZLIssueSectionAttachments]) {
        OZLIssueAttachmentGalleryCell *cell = [tableView dequeueReusableCellWithIdentifier:OZLAttachmentsReuseIdentifier forIndexPath:indexPath];
        cell.contentPadding = 16.;
        cell.attachments = self.viewModel.issueModel.attachments;
        cell.delegate = self;
        
        return cell;
        
    } else if ([sectionName isEqualToString:OZLIssueSectionRecentActivity]) {
        OZLJournalCell *cell = [tableView dequeueReusableCellWithIdentifier:OZLRecentActivityReuseIdentifier forIndexPath:indexPath];
        
        OZLModelJournal *journal = [self.viewModel recentActivityAtIndex:indexPath.row];
        cell.contentPadding = OZLContentPadding;
        cell.journal = journal;
        
        return cell;
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.currentSectionNames.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionName = self.viewModel.currentSectionNames[indexPath.section];
    
    if ([sectionName isEqualToString:OZLIssueSectionDetail]) {
        return self.detailView.intrinsicHeight;
        
    } else if ([sectionName isEqualToString:OZLIssueSectionDescription]) {
        return [OZLIssueDescriptionCell heightWithWidth:tableView.frame.size.width
                                           description:self.viewModel.issueModel.description
                                        contentPadding:OZLContentPadding];
        
    } else if ([sectionName isEqualToString:OZLIssueSectionAttachments]) {
        return 110.;
        
    } else if ([sectionName isEqualToString:OZLIssueSectionRecentActivity]) {
        OZLModelJournal *journal = [self.viewModel recentActivityAtIndex:indexPath.row];
        
        return [OZLJournalCell heightWithWidth:self.view.frame.size.width contentPadding:OZLContentPadding journalModel:journal];
    }
    
    return 44.;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *sectionName = self.viewModel.currentSectionNames[section];
    
    if ([sectionName isEqualToString:OZLIssueSectionDetail]) {
        return 0.;
    }
    
    return 40.;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionName = self.viewModel.currentSectionNames[section];
    
    OZLIssueSectionHeaderView *header = [[OZLIssueSectionHeaderView alloc] init];
    header.contentPadding = OZLContentPadding;
    header.titleLabel.text = [self.viewModel displayNameForSectionName:sectionName];
    
    if ([sectionName isEqualToString:OZLIssueSectionRecentActivity]) {
        [header.disclosureButton setTitle:@"Show all \u203a" forState:UIControlStateNormal];
        [header.disclosureButton addTarget:self action:@selector(showAllActivityAction:) forControlEvents:UIControlEventTouchUpInside];
    } else if ([sectionName isEqualToString:OZLIssueSectionDescription]) {
        [header.disclosureButton setTitle:@"Show full description \u203a" forState:UIControlStateNormal];
        [header.disclosureButton addTarget:self action:@selector(showFullDescriptionAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - DRPSlidingTabViewDelegate
- (void)view:(UIView *)view intrinsicHeightDidChangeTo:(CGFloat)newHeight {
    if (view == self.detailView) {
        [self.tableView beginUpdates];
        self.detailView.frame = self.detailView.superview.bounds;
        [self.tableView endUpdates];
    }
}

#pragma mark - OZLIssueViewModelDelegate
- (void)viewModel:(OZLIssueViewModel *)viewModel didFinishLoadingIssueWithError:(NSError *)error {
    [self hideLoadingSpinner];
    [self applyIssueModel:self.viewModel.issueModel];
    [self.tableView reloadData];
    [self informAncestorsIssueChanged];
}

- (void)viewModelIssueContentDidChange:(OZLIssueViewModel *)viewModel {
    [self applyIssueModel:self.viewModel.issueModel];
    [self.tableView reloadData];
    [self informAncestorsIssueChanged];
}

- (void)informAncestorsIssueChanged {
    __weak OZLIssueViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIViewController *vc in weakSelf.navigationController.viewControllers) {
            if (vc == weakSelf) {
                continue;
            }
            
            if ([vc conformsToProtocol:@protocol(OZLNavigationChildChangeListener)]) {
                id<OZLNavigationChildChangeListener> listener = (id<OZLNavigationChildChangeListener>)vc;
                [listener navigationChild:weakSelf didModifyIssue:weakSelf.viewModel.issueModel];
            }
        }
    });
}

#pragma mark - OZLIssueAttachmentGalleryCellDelegate
- (void)galleryCell:(OZLIssueAttachmentGalleryCell *)galleryCell didSelectAttachment:(OZLModelAttachment *)attachment withCellRelativeFrame:(CGRect)frame thumbnailImage:(UIImage *)thumbnailImage {
    
    if ([attachment.contentType hasPrefix:@"video"] || [attachment.contentType containsString:@"mp4"]) {
        
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
        playerVC.player = [AVPlayer playerWithURL:[NSURL URLWithString:attachment.contentURL]];
        playerVC.showsPlaybackControls = YES;
        
        [self presentViewController:playerVC animated:YES completion:nil];
        
    } else if ([attachment.contentType hasPrefix:@"image"]) {
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.placeholderImage = thumbnailImage;
        imageInfo.imageURL = [NSURL URLWithString:attachment.contentURL];
        
        JTSImageViewController *imageController = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                               mode:JTSImageViewControllerMode_Image backgroundStyle:JTSImageViewControllerBackgroundOption_None];
        
        [imageController showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];
        
    } else if ([attachment.contentType isEqualToString:@"text/plain"]) {
        OZLWebViewController *textVC = [[OZLWebViewController alloc] init];
        textVC.sourceURL = [NSURL URLWithString:attachment.contentURL];
        
        [self.navigationController pushViewController:textVC animated:YES];
    }
}

#pragma mark - Transitioning
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[OZLSheetPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end
