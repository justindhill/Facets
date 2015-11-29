//
//  OZLModelUser.m
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

@implementation OZLModelUser

- (id)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        _index = [[dic objectForKey:@"id"] intValue];
        _login = [dic objectForKey:@"login"];
        _firstname = [dic objectForKey:@"firstname"];
        _lastname = [dic objectForKey:@"lastname"];
        _mail = [dic objectForKey:@"mail"];
        _createdOn = [dic objectForKey:@"created_on"];
        _lastLoginIn = [dic objectForKey:@"last_login_on"];

        _name = [dic objectForKey:@"name"];
        
        if (_name == nil) {
            _name = _login;
        }
    }

    return  self;
}

@end
