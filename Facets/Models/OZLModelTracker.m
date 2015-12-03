//
//  OZLModelTracker.m
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

#import "OZLModelTracker.h"

@implementation OZLModelTracker

+ (NSString *)primaryKey {
    return @"trackerId";
}

- (id)initWithAttributeDictionary:(NSDictionary *)attributes {
    
    if (self = [super init]) {
        [self applyAttributeDictionary:attributes];
    }

    return self;
}

- (void)applyAttributeDictionary:(NSDictionary *)attributes {
    self.trackerId = [[attributes objectForKey:@"id"] intValue];
    self.name = [attributes objectForKey:@"name"];
}

@end
