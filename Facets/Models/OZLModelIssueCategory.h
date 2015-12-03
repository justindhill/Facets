//
//  OZLModelIssueCategory.h
//  RedmineMobile
//
//  Created by lizhijie on 7/16/13.

@interface OZLModelIssueCategory : RLMObject

@property (nonatomic) NSInteger categoryId;
@property (nonatomic, strong) NSString *name;

- (id)initWithAttributeDictionary:(NSDictionary *)attributes;

@end
