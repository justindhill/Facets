//
//  OZLModelIssuePriority.m
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

@implementation OZLModelIssuePriority

- (id)initWithDictionary:(NSDictionary *)dic {
    
    if (self = [super init]) {
        _index = [[dic objectForKey:@"id"] integerValue];
        _name = [dic objectForKey:@"name"];
    }

    return self;
}

@end
