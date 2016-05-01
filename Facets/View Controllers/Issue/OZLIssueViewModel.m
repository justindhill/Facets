//
//  OZLIssueViewModel.m
//  Facets
//
//  Created by Justin Hill on 11/11/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLIssueViewModel.h"
#import "OZLNetwork.h"
#import "Facets-Swift.h"

NSString * const OZLIssueSectionDetail = @"OZLIssueSectionDetail";
NSString * const OZLIssueSectionDescription = @"OZLIssueSectionDescription";
NSString * const OZLIssueSectionAttachments = @"OZLIssueSectionAttachments";
NSString * const OZLIssueSectionRecentActivity = @"OZLIssueSectionRecentActivity";

@interface OZLIssueViewModel ()

@property BOOL successfullyFetchedIssue;
@property (strong) NSArray *currentSectionNames;

@end

@implementation OZLIssueViewModel

#pragma mark - Life cycle
- (instancetype)initWithIssueModel:(OZLModelIssue *)issueModel {
    if (self = [super init]) {
        self.issueModel = issueModel;
        self.successfullyFetchedIssue = NO;
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithIssueModel:nil];
}

#pragma mark - Accessors
- (void)setIssueModel:(OZLModelIssue *)issueModel {
    _issueModel = issueModel;
    [self updateSectionNames];
}

- (OZLIssueCompleteness)completeness {
    if (self.successfullyFetchedIssue) {
        return OZLIssueCompletenessAll;
        
    } else if (self.issueModel.subject) {
        return OZLIssueCompletenessSome;
        
    } else {
        return OZLIssueCompletenessNone;
    }
}

- (NSInteger)recentActivityCount {
    return MIN(self.issueModel.journals.count, 3);
}

- (OZLModelJournal *)recentActivityAtIndex:(NSInteger)index {
    NSAssert(index >= 0 && index < self.recentActivityCount, @"Requested invalid recent activity index");
    
    if (!(index >= 0 && index < self.recentActivityCount)) {
        return nil;
    }
    
    NSInteger baseJournalIndex = self.issueModel.journals.count - self.recentActivityCount;
    NSInteger activityIndex = baseJournalIndex + index;
    OZLModelJournal *activity = self.issueModel.journals[activityIndex];
    
    return activity;
}

#pragma mark - Behavior
- (void)updateSectionNames {
    NSMutableArray *names = [NSMutableArray arrayWithObjects:OZLIssueSectionDetail, nil];
    
    if (self.issueModel.issueDescription.length > 0) {
        [names addObject:OZLIssueSectionDescription];
    }
    
    if (self.issueModel.attachments.count > 0) {
        [names addObject:OZLIssueSectionAttachments];
    }
    
    if (self.issueModel.journals.count > 0) {
        [names addObject:OZLIssueSectionRecentActivity];
    }
    
    self.currentSectionNames = names;
}

- (NSString *)displayNameForSectionName:(NSString *)sectionName {
    if ([sectionName isEqualToString:OZLIssueSectionAttachments]) {
        return @"ATTACHMENTS";
    } else if ([sectionName isEqualToString:OZLIssueSectionDescription]) {
        return @"DESCRIPTION";
    } else if ([sectionName isEqualToString:OZLIssueSectionRecentActivity]) {
        return @"RECENT ACTIVITY";
    }
    
    return nil;
}

- (void)loadIssueData {
    NSDictionary *params = @{ @"include": @"attachments,journals" };
    __weak OZLIssueViewModel *weakSelf = self;
    
    [[OZLNetwork sharedInstance] getDetailForIssue:self.issueModel.index withParams:params completion:^(OZLModelIssue *result, NSError *error) {
        
        if (result) {
            weakSelf.successfullyFetchedIssue = YES;
            weakSelf.issueModel = result;
        }
        
        if ([weakSelf.delegate respondsToSelector:@selector(viewModel:didFinishLoadingIssueWithError:)]) {
            [weakSelf.delegate viewModel:weakSelf didFinishLoadingIssueWithError:error];
        }
    }];
}

- (void)quickAssignController:(OZLQuickAssignViewController *)quickAssign didChangeAssigneeInIssue:(OZLModelIssue *)issue from:(OZLModelUser * _Nullable)from to:(OZLModelUser * _Nullable)to {
    self.issueModel = issue;
    
    OZLModelJournal *journal = [[OZLModelJournal alloc] init];
    journal.creationDate = [NSDate date];
    
    OZLModelJournalDetail *detail = [[OZLModelJournalDetail alloc] init];
    detail.type = OZLModelJournalDetailTypeAttribute;
    detail.oldValue = [NSString stringWithFormat:@"%ld", (long)from.userId];
    detail.newValue = [NSString stringWithFormat:@"%ld", (long)to.userId];
    detail.name = @"assigned_to_id";
    
    journal.details = @[ detail ];
    issue.journals = [issue.journals arrayByAddingObject:journal];
    
    if ([self.delegate respondsToSelector:@selector(viewModelIssueContentDidChange:)]) {
        [self.delegate viewModelIssueContentDidChange:self];
    }
}

@end
