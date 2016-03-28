//
//  OZLModelIssueStatus.m
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

#import "OZLModelIssueStatus.h"
#import "Facets-Swift.h"

@interface OZLModelIssueStatus () <OZLEnumerationFormFieldValue>

@end

@implementation OZLModelIssueStatus

+ (NSString *)primaryKey {
    return @"statusId";
}

- (id)initWithAttributeDictionary:(NSDictionary *)attributes {
    
    if (self = [super init]) {
        [self applyAttributeDictionary:attributes];
    }
    
    return self;
}

- (void)applyAttributeDictionary:(NSDictionary *)attributes {
    self.statusId = [[attributes objectForKey:@"id"] integerValue];
    self.name = [attributes objectForKey:@"name"];
}

- (NSString *)stringValue {
    return self.name;
}

@end
