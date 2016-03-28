//
//  OZLModelIssuePriority.m
//  Facets
//
//  Created by lizhijie on 7/15/13.

@implementation OZLModelIssuePriority

+ (NSString *)primaryKey {
    return @"priorityId";
}

- (id)initWithAttributeDictionary:(NSDictionary *)attributes {
    if (self = [super init]) {
        [self applyAttributeDictionary:attributes];
    }

    return self;
}

- (void)applyAttributeDictionary:(NSDictionary *)attributes {
    self.priorityId = [[attributes objectForKey:@"id"] integerValue];
    self.name = [attributes objectForKey:@"name"];
}

@end
