//
//  OZLModelIssueCategory.h
//  Facets
//
//  Created by lizhijie on 7/16/13.

@protocol OZLEnumerationFormFieldValue;

@interface OZLModelIssueCategory : RLMObject <OZLEnumerationFormFieldValue>

@property (nonatomic) NSInteger categoryId;
@property (nonatomic, strong) NSString *name;

- (id)initWithAttributeDictionary:(NSDictionary *)attributes;

@end
