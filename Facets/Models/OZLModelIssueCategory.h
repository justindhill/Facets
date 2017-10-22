//
//  OZLModelIssueCategory.h
//  Facets
//
//  Created by lizhijie on 7/16/13.

@protocol OZLEnumerationFormFieldValue;

// Compiler quirk - OZLEnumerationFormFieldValue is declared in Swift.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
@interface OZLModelIssueCategory : RLMObject <OZLEnumerationFormFieldValue>
#pragma clang diagnostic pop

@property (nonatomic) NSInteger categoryId;
@property (nonatomic, strong) NSString *name;

- (id)initWithAttributeDictionary:(NSDictionary *)attributes;

@end
