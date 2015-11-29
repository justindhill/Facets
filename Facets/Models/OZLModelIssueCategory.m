//
//  OZLModelIssueCategory.m
//  RedmineMobile
//
//  Created by lizhijie on 7/16/13.

#import "OZLModelIssueCategory.h"

@implementation OZLModelIssueCategory

- (id)initWithDictionary:(NSDictionary *)dic {
    
    if (self = [super init]) {
        _index = [[dic objectForKey:@"id"] intValue];
        _name = [dic objectForKey:@"name"];
    }
    
    return self;
}

- (NSMutableDictionary *)toParametersDic {
    return nil;
}

@end
