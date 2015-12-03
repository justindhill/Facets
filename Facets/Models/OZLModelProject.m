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
    return @"projectId";
}

- (id)initWithAttributeDictionary:(NSDictionary *)attributes {
    
    if (self = [super init]) {
        [self applyAttributeDictionary:attributes];
    }
    
    return self;
}

- (void)applyAttributeDictionary:(NSDictionary *)attributes {
    self.projectId = [[attributes objectForKey:@"id"] intValue];
    self.identifier = [attributes objectForKey:@"identifier"];
    self.name = [attributes objectForKey:@"name"];
    self.description = [attributes objectForKey:@"description"];
    self.homepage = [attributes objectForKey:@"homepage"];
    self.createdOn = [attributes objectForKey:@"created_on"];
    self.updatedOn = [attributes objectForKey:@"updated_on"];
    
    NSDictionary *parent = [attributes objectForKey:@"parent"];
    
    if ([parent isKindOfClass:[NSDictionary class]]) {
        _parentId = [[parent objectForKey:@"id"] intValue];
    } else {
        _parentId = -1;
    }
    
    NSArray *categoryDicts = attributes[@"issue_categories"];
    
    if ([categoryDicts isKindOfClass:[NSArray class]]) {
        for (NSDictionary *categoryDict in categoryDicts) {
            [self.issueCategories addObject:[[OZLModelIssueCategory alloc] initWithAttributeDictionary:categoryDict]];
        }
    }
    
    NSArray *trackerDicts = attributes[@"trackers"];
    
    if ([trackerDicts isKindOfClass:[NSArray class]]) {
        for (NSDictionary *trackerDict in trackerDicts) {
            [self.trackers addObject:[[OZLModelTracker alloc] initWithAttributeDictionary:trackerDict]];
        }
    }
}

@end
