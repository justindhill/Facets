//
//  OZLModelIssueCategory.m
//  Facets
//
//  Created by lizhijie on 7/16/13.

#import "OZLModelIssueCategory.h"

@implementation OZLModelIssueCategory

+ (NSString *)primaryKey {
    return @"categoryId";
}

- (id)initWithAttributeDictionary:(NSDictionary *)attributes {
    if (self = [super init]) {
        [self applyAttributeDictionary:attributes];
    }
    
    return self;
}

- (void)applyAttributeDictionary:(NSDictionary *)attributes {
    self.categoryId = [[attributes objectForKey:@"id"] integerValue];
    self.name = [attributes objectForKey:@"name"];
}

@end
