//
//  OZLModelIssueStatus.h
//  Facets
//
//  Created by lizhijie on 7/15/13.

@import Foundation;

@interface OZLModelIssueStatus : RLMObject

@property (nonatomic) NSInteger statusId;
@property (nonatomic, strong) NSString *name;

- (id)initWithAttributeDictionary:(NSDictionary *)attributes;

@end
