//
//  OZLModelQuery.m
//  RedmineMobile
//
//  Created by Justin Hill on 10/15/15.
//  Copyright © 2015 Lee Zhijie. All rights reserved.
//

#import "OZLModelQuery.h"

@implementation OZLModelQuery

- (id)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        self.queryId = [dic[@"id"] integerValue];
        self.name = dic[@"name"];
        self.projectId = [dic[@"project_id"] integerValue];
    }
    
    return self;
}

@end
