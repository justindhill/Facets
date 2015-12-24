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
#import "OZLModelVersion.h"
#import "OZLModelAttachment.h"
#import "OZLModelCustomField.h"

@class OZLModelJournal;

@interface OZLModelIssue : NSObject

/**
 *  @brief Whether or not changes to the model's properties affect the diff dictionary
 */
@property (nonatomic, assign) BOOL modelDiffingEnabled;

/**
 *  @brief If modelDiffingEnabled is YES, this dictionary contains a server-compatible
 *         dictionary containing the changes that have been tracked, otherwise nil.
 */
@property (nullable, readonly) NSDictionary *changeDictionary;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger projectId;
@property (nonatomic, assign) NSInteger parentIssueId;
@property (nullable, nonatomic, strong) OZLModelTracker *tracker;
@property (nullable, nonatomic, strong) OZLModelUser *author;
@property (nullable, nonatomic, strong) OZLModelUser *assignedTo;
@property (nullable, nonatomic, strong) OZLModelIssuePriority *priority;
@property (nullable, nonatomic, strong) OZLModelIssueStatus *status;
@property (nullable, nonatomic, strong) OZLModelIssueCategory *category;
@property (nullable, nonatomic, strong) OZLModelVersion *targetVersion;
@property (nullable, nonatomic, strong) NSArray<OZLModelCustomField *> *customFields;
@property (nullable, nonatomic, strong) NSString *subject;
@property (nullable, nonatomic, strong) NSString *description;
@property (nullable, nonatomic, strong) NSDate *startDate;
@property (nullable, nonatomic, strong) NSDate *dueDate;
@property (nullable, nonatomic, strong) NSDate *createdOn;
@property (nullable, nonatomic, strong) NSDate *updatedOn;
@property (nonatomic, assign) float doneRatio;
@property (nonatomic, assign) float spentHours;
@property (nonatomic, assign) float estimatedHours;
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

+ (nullable NSString *)displayValueForAttributeName:(nullable NSString *)name attributeId:(NSInteger)attributeId;
+ (nonnull NSString *)displayNameForAttributeName:(nonnull NSString *)attributeName;

@end
