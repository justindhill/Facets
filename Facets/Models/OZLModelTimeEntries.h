//
//  OZLModelTimeEntries.h
//  Facets
//
//  Created by lizhijie on 7/22/13.

@import Foundation;
#import "OZLModelProject.h"
#import "OZLModelUser.h"
#import "OZLModelTimeEntryActivity.h"

@class OZLModelIssue;

@interface OZLModelTimeEntries : NSObject

@property (nonatomic) NSInteger index;
@property (nonatomic, strong) OZLModelProject *project;
@property (nonatomic, strong) OZLModelUser *user;
@property (nonatomic, strong) OZLModelIssue *issue;
@property (nonatomic, strong) OZLModelTimeEntryActivity *activity;
@property (nonatomic) float hours;
@property (nonatomic, strong) NSString *comments;
@property (nonatomic, strong) NSString *spentOn;
@property (nonatomic, strong) NSString *createdOn;
@property (nonatomic, strong) NSString *updatedOn;

- (id)initWithDictionary:(NSDictionary *)dic;
- (NSMutableDictionary *)toParametersDic;

@end
