//
//  OZLModelMembership.m
//  Facets
//
//  Created by Justin Hill on 12/24/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLModelMembership.h"

@implementation OZLModelMembership

+ (NSString *)primaryKey {
    return @"membershipId";
}

+ (NSArray<NSString *> *)indexedProperties {
    return @[ @"projectId" ];
}

// I really only care about the user here, so this model will be very incomplete
- (instancetype)initWithAttributeDictionary:(NSDictionary *)attributes {
    if (self = [super init]) {
        [self applyAttributeDictionary:attributes];
    }
    
    return self;
}

- (void)applyAttributeDictionary:(NSDictionary *)attributes {
    NSDictionary *userDict = attributes[@"user"];
    NSDictionary *projectDict = attributes[@"project"];
    
    self.membershipId = [attributes[@"id"] integerValue];
    
    if ([projectDict isKindOfClass:[NSDictionary class]]) {
        OZLModelProject *project = [[OZLModelProject alloc] initWithAttributeDictionary:projectDict];
        self.projectId = project.projectId;
    }
    
    if ([userDict isKindOfClass:[NSDictionary class]]) {
        self.user = [[OZLModelUser alloc] initWithAttributeDictionary:userDict];
    }
}

@end
