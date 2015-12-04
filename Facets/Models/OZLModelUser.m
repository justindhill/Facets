//
//  OZLModelUser.m
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

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
    self.userId = [[attributes objectForKey:@"id"] integerValue];
    self.login = [attributes objectForKey:@"login"];
    self.firstname = [attributes objectForKey:@"firstname"];
    self.lastname = [attributes objectForKey:@"lastname"];
    self.mail = [attributes objectForKey:@"mail"];
    
    NSString *creationDateString = [attributes objectForKey:@"created_on"];
    
    if ([creationDateString isKindOfClass:[NSString class]]) {
        self.creationDate = [NSDate dateWithISO8601String:creationDateString];
    }
    
    NSString *lastLoginString = [attributes objectForKey:@"last_login_on"];
    
    if ([lastLoginString isKindOfClass:[NSString class]]) {
        self.lastLoginDate = [NSDate dateWithISO8601String:lastLoginString];
    }

    NSString *name = [attributes objectForKey:@"name"];
    
    if (name) {
        self.name = name;
    }
}

@end
