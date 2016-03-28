//
//  OZLModelProject.h
//  Facets
//
//  Created by Lee Zhijie on 7/15/13.

#import <Foundation/Foundation.h>
#import "OZLModelIssueCategory.h"
#import "OZLModelTracker.h"

RLM_ARRAY_TYPE(OZLModelIssueCategory)
RLM_ARRAY_TYPE(OZLModelTracker)

@interface OZLModelProject : RLMObject

@property (nonatomic) NSInteger projectId;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger parentId;
@property (nonatomic) BOOL isPublic;
@property (nonatomic, strong) NSString *homepage;
@property (nonatomic, strong) NSString *createdOn;
@property (nonatomic, strong) NSString *updatedOn;

@property RLMArray<OZLModelIssueCategory *><OZLModelIssueCategory> *issueCategories;
@property RLMArray<OZLModelTracker *><OZLModelTracker> *trackers;

- (id)initWithAttributeDictionary:(NSDictionary *)attributes;

@end
