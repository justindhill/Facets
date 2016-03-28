//
//  OZLModelTracker.m
//  Facets
//
//  Created by lizhijie on 7/15/13.

#import "OZLModelTracker.h"
#import "Facets-Swift.h"

@interface OZLModelTracker () <OZLEnumerationFormFieldValue>

@end

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
    self.trackerId = [[attributes objectForKey:@"id"] integerValue];
    self.name = [attributes objectForKey:@"name"];
}

- (NSString *)stringValue {
    return self.name;
}

@end
