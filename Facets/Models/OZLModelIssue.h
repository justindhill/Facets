//
//  OZLModelIssue.h
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

#import <Foundation/Foundation.h>
#import "OZLModelTracker.h"
#import "OZLModelIssueStatus.h"
#import "OZLModelUser.h"
#import "OZLModelIssuePriority.h"
#import "OZLModelIssueCategory.h"
#import "OZLModelIssueTargetVersion.h"
#import "OZLModelAttachment.h"

@class OZLModelJournal;

@interface OZLModelIssue : NSObject

@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger projectId;
@property (nonatomic) NSInteger parentIssueId;
@property (nonatomic, strong) OZLModelTracker *tracker;
@property (nonatomic, strong) OZLModelUser *author;
@property (nonatomic, strong) OZLModelUser *assignedTo;
@property (nonatomic, strong) OZLModelIssuePriority *priority;
@property (nonatomic, strong) OZLModelIssueStatus *status;
@property (nonatomic, strong) OZLModelIssueCategory *category;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *dueDate;
@property (nonatomic, strong) NSString *createdOn;
@property (nonatomic, strong) NSString *updatedOn;
@property (nonatomic, strong) OZLModelIssueTargetVersion *targetVersion;
@property (nonatomic) float doneRatio;
@property (nonatomic) float spentHours;
@property (nonatomic) float estimatedHours;
@property (nonatomic, strong) NSString *notes;// used as paramter to update a issue

/**
 *  @brief Attachments attached to the issue.
 */
@property (strong) NSArray<OZLModelAttachment *> *attachments;

/**
 *  @brief Journals attached to the issue
 */
@property (strong) NSArray<OZLModelJournal *> *journals;

- (id)initWithDictionary:(NSDictionary *)dic;
- (NSMutableDictionary *)toParametersDic;

@end
