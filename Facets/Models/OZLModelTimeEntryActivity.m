//
//  OZLModelTimeEntryActivity.m
//  RedmineMobile
//
//  Created by lizhijie on 7/23/13.

#import "OZLModelTimeEntryActivity.h"

@implementation OZLModelTimeEntryActivity

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
