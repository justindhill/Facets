//
//  OZLModelTimeEntries.m
//  RedmineMobile
//
//  Created by lizhijie on 7/22/13.

#import "OZLModelTimeEntries.h"

@implementation OZLModelTimeEntries

- (id)initWithDictionary:(NSDictionary *)dic {
    
    if (self = [super init]) {
        _index = [[dic objectForKey:@"id"] integerValue];
        id project = [dic objectForKey:@"project"];
        
        if (project != nil) {
            _project = [[OZLModelProject alloc] initWithAttributeDictionary:project];
        }
        
        id user = [dic objectForKey:@"user"];
        
        if (user != nil) {
            _user = [[OZLModelUser alloc] initWithAttributeDictionary:user];
        }
        
        id issue = [dic objectForKey:@"issue"];
        
        if (issue != nil ) {
            _issue = [[OZLModelIssue alloc] initWithDictionary:issue];
        }
        
        id activity = [dic objectForKey:@"activity"];
        
        if (activity != nil) {
            _activity = [[OZLModelTimeEntryActivity alloc] initWithDictionary:activity];
        }
        
        _hours = [[dic objectForKey:@"hours"] floatValue];
        _comments = [dic objectForKey:@"comments"];
        _spentOn = [dic objectForKey:@"spent_on"];
        _createdOn = [dic objectForKey:@"created_on"];
        _updatedOn = [dic objectForKey:@"updated_on"];
    }
    
    return self;
}

- (NSMutableDictionary *)toParametersDic {
    
    NSMutableDictionary *entryDic = [[NSMutableDictionary alloc] init];
    [entryDic setObject:[NSNumber numberWithFloat:_hours] forKey:@"hours"];//required
    
    if (_issue) {
        [entryDic setObject:[NSNumber numberWithInteger:_issue.index] forKey:@"issue_id"];
    } else if (_project) {
        [entryDic setObject:[NSNumber numberWithInteger:_project.projectId] forKey:@"project_id"];
    }
    
    if (_spentOn) {
        [entryDic setObject:_spentOn forKey:@"spent_on"];
    }
    
    if (_activity) {
        [entryDic setObject:[NSNumber numberWithInteger:_activity.index] forKey:@"activity_id"];
    }
    
    if (_comments) {
        [entryDic setObject:_comments forKey:@"comments"];
    }
    
    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:entryDic, @"time_entry", nil];
}

@end
