//
//  OZLModelIssueTargetVersion.m
//  Facets
//
//  Created by Justin Hill on 11/7/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLModelIssueTargetVersion.h"

@implementation OZLModelIssueTargetVersion

- (id)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        self.targetVersionId = [dic[@"fixed_version"] integerValue];
        self.name = dic[@"name"];
    }
    
    return self;
}


@end
