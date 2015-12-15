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
#import "OZLModelCustomField.h"

@class OZLModelJournal;

@interface OZLModelIssue : NSObject

@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger projectId;
@property (nonatomic) NSInteger parentIssueId;
@property (nullable, nonatomic, strong) OZLModelTracker *tracker;
@property (nullable, nonatomic, strong) OZLModelUser *author;
@property (nullable, nonatomic, strong) OZLModelUser *assignedTo;
@property (nullable, nonatomic, strong) OZLModelIssuePriority *priority;
@property (nullable, nonatomic, strong) OZLModelIssueStatus *status;
@property (nullable, nonatomic, strong) OZLModelIssueCategory *category;
@property (nullable, nonatomic, strong) NSArray<OZLModelCustomField *> *customFields;
@property (nullable, nonatomic, strong) NSString *subject;
@property (nullable, nonatomic, strong) NSString *description;
@property (nullable, nonatomic, strong) NSString *startDate;
@property (nullable, nonatomic, strong) NSString *dueDate;
@property (nullable, nonatomic, strong) NSString *createdOn;
@property (nullable, nonatomic, strong) NSString *updatedOn;
@property (nullable, nonatomic, strong) OZLModelIssueTargetVersion *targetVersion;
@property (nonatomic) float doneRatio;
@property (nonatomic) float spentHours;
@property (nonatomic) float estimatedHours;
@property (nullable, nonatomic, strong) NSString *notes;// used as paramter to update a issue

/**
 *  @brief Attachments attached to the issue.
 */
@property (nullable, strong) NSArray<OZLModelAttachment *> *attachments;

/**
 *  @brief Journals attached to the issue
 */
@property (nullable, strong) NSArray<OZLModelJournal *> *journals;

- (nonnull id)initWithDictionary:(nonnull NSDictionary *)dic;
- (nonnull NSMutableDictionary *)toParametersDic;

+ (nullable NSString *)displayValueForAttributeName:(nullable NSString *)name attributeId:(NSInteger)attributeId;
+ (nonnull NSString *)displayNameForAttributeName:(nonnull NSString *)attributeName;

@end
