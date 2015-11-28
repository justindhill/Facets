//
//  OZLIssueViewModel.h
//  Facets
//
//  Created by Justin Hill on 11/11/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OZLModelIssue.h"

extern NSString * const OZLIssueSectionDetail;
extern NSString * const OZLIssueSectionDescription;
extern NSString * const OZLIssueSectionAttachments;
extern NSString * const OZLIssueSectionRecentActivity;

typedef NS_ENUM(NSInteger, OZLIssueCompleteness) {
    OZLIssueCompletenessNone,
    OZLIssueCompletenessSome,
    OZLIssueCompletenessAll
};

@class OZLIssueViewModel;
@protocol OZLIssueViewModelDelegate <NSObject>

- (void)viewModel:(OZLIssueViewModel *)viewModel didFinishLoadingIssueWithError:(NSError *)error;

@end

@interface OZLIssueViewModel : NSObject

- (instancetype)initWithIssueModel:(OZLModelIssue *)issueModel NS_DESIGNATED_INITIALIZER;
- (void)loadIssueData;
- (OZLModelJournal *)recentActivityAtIndex:(NSInteger)index;
- (NSString *)displayNameForSectionName:(NSString *)sectionName;


@property (weak) id<OZLIssueViewModelDelegate> delegate;
@property (nonatomic, strong) OZLModelIssue *issueModel;
@property (readonly) NSArray *currentSectionNames;
@property (readonly) OZLIssueCompleteness completeness;
@property (readonly) NSInteger recentActivityCount;

@end
