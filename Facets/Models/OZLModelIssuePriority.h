//
//  OZLModelIssuePriority.h
//  Facets
//
//  Created by lizhijie on 7/15/13.

#import <Foundation/Foundation.h>

@interface OZLModelIssuePriority : RLMObject

@property (nonatomic) NSInteger priorityId;
@property (nonatomic, strong) NSString *name;

- (id)initWithAttributeDictionary:(NSDictionary *)attributes;

@end
