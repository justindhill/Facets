//
//  OZLModelMembership.m
//  Facets
//
//  Created by Justin Hill on 12/24/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLModelMembership.h"

@implementation OZLModelMembership

// I really only care about the user here, so this model will be very incomplete
- (instancetype)initWithAttributeDictionary:(NSDictionary *)attributes {
    if (self = [super init]) {
        [self applyAttributeDictionary:attributes];
    }
    
    return self;
}

- (void)applyAttributeDictionary:(NSDictionary *)attributes {
    NSDictionary *userDict = attributes[@"user"];
    
    if ([userDict isKindOfClass:[NSDictionary class]]) {
        self.user = [[OZLModelUser alloc] initWithAttributeDictionary:userDict];
    }
}

@end
