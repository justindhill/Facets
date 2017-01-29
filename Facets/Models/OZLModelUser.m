//
//  OZLModelUser.m
//  Facets
//
//  Created by lizhijie on 7/15/13.

@import ISO8601;

#import "Facets-Swift.h"

@implementation OZLModelUser

+ (NSString *)primaryKey {
    return @"userId";
}

- (id)initWithAttributeDictionary:(NSDictionary *)attributes {
    if (self = [super init]) {
        [self applyAttributeDictionary:attributes];
    }

    return  self;
}

- (void)applyAttributeDictionary:(NSDictionary *)attributes {
    self.userId = [[attributes objectForKey:@"id"] stringValue];
    self.login = [attributes objectForKey:@"login"];
    self.mail = [attributes objectForKey:@"mail"];
    
    NSString *creationDateString = [attributes objectForKey:@"created_on"];
    
    if ([creationDateString isKindOfClass:[NSString class]]) {
        self.creationDate = [NSDate dateWithISO8601String:creationDateString];
    }
    
    NSString *lastLoginString = [attributes objectForKey:@"last_login_on"];
    
    if ([lastLoginString isKindOfClass:[NSString class]]) {
        self.lastLoginDate = [NSDate dateWithISO8601String:lastLoginString];
    }

    NSString *firstName = [attributes objectForKey:@"firstname"];
    NSString *lastName = [attributes objectForKey:@"lastname"];

    if (firstName && lastName) {
        self.name = [@[ firstName, lastName ] componentsJoinedByString:@" "];
    } else if ([attributes.allKeys containsObject:@"name"]) {
        self.name = attributes[@"name"];
    }
}

- (NSString *)stringValue {
    return self.name;
}

- (NSURL *)sizedGravatarURL:(NSInteger)sideLen {
    NSURLComponents *components = [NSURLComponents componentsWithString:self.gravatarURL];
    components.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"rating" value:@"PG"],
        [NSURLQueryItem queryItemWithName:@"size" value:[@(sideLen) stringValue]],
        [NSURLQueryItem queryItemWithName:@"default" value:@""]
    ];

    return [components URL];
}

@end
