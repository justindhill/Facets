//
//  OZLModelTracker.m
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

#import "OZLModelTracker.h"

@implementation OZLModelTracker

+ (NSString *)primaryKey {
    return @"index";
}

- (id)initWithDictionary:(NSDictionary *)dic {
    
    if (self = [super init]) {
        _index = [[dic objectForKey:@"id"] intValue];
        _name = [dic objectForKey:@"name"];
    }

    return self;
}

@end
