//
//  OZLModelProject.m
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/15/13.

// This code is distributed under the terms and conditions of the MIT license.

#import "OZLModelProject.h"

@implementation OZLModelProject

@synthesize description = _description;

+ (NSString *)primaryKey {
    return @"index";
}

- (id)initWithDictionary:(NSDictionary *)dic {
    
    if (self = [super init]) {

        _index = [[dic objectForKey:@"id"] intValue];
        _identifier = [dic objectForKey:@"identifier"];
        _name = [dic objectForKey:@"name"];
        _description = [dic objectForKey:@"description"];
        _homepage = [dic objectForKey:@"homepage"];
        _createdOn = [dic objectForKey:@"created_on"];
        _updatedOn = [dic objectForKey:@"updated_on"];
        NSDictionary *parent = [dic objectForKey:@"parent"];
        
        if (parent) {
            _parentId = [[parent objectForKey:@"id"] intValue];
        } else {
            _parentId = -1;
        }
    }
    
    return self;
}

- (NSMutableDictionary *)toParametersDic {
    NSMutableDictionary *projectDic = [[NSMutableDictionary alloc] init];
    [projectDic setObject:_name forKey:@"name"];
    [projectDic setObject:_identifier forKey:@"identifier"];
    
    if (_description.length > 0) {
        [projectDic setObject:_description forKey:@"description"];
    }
    
    if (_parentId > 0) {
        [projectDic setObject:[NSNumber numberWithInteger:_parentId] forKey:@"parent_id"];
    }
    
    if (_homepage.length > 0) {
        [projectDic setObject:_homepage forKey:@"homepage"];
    }

    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:projectDic, @"project", nil];
}

@end
