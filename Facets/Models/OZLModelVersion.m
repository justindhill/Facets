//
//  OZLModelVersion.m
//  Facets
//
//  Created by Justin Hill on 12/2/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLModelVersion.h"
#import "Facets-Swift.h"

@implementation OZLModelVersion

+ (NSString *)primaryKey {
    return @"versionId";
}

- (instancetype)initWithAttributeDictionary:(NSDictionary *)attributes {
    if (self = [super init]) {
        [self applyAttributeDictionary:attributes];
    }
    
    return self;
}

- (void)applyAttributeDictionary:(NSDictionary *)attributes {
    self.versionId = [attributes[@"id"] integerValue];
    self.projectId = [attributes[@"project"][@"id"] integerValue];
    self.name = attributes[@"name"];
    self.versionDescription = attributes[@"description"];
    self.status = [self statusValueForString:attributes[@"status"]];
    
    NSString *dueDateString = attributes[@"due_date"];
    NSString *creationDateString = attributes[@"created_on"];
    NSString *lastUpdatedString = attributes[@"updated_on"];
    
    if ([dueDateString isKindOfClass:[NSString class]]) {
        self.dueDate = [NSDate dateWithISO8601String:dueDateString];
    }
    
    if ([creationDateString isKindOfClass:[NSString class]]) {
        self.creationDate = [NSDate dateWithISO8601String:creationDateString];
    }
    
    if ([lastUpdatedString isKindOfClass:[NSString class]]) {
        self.lastUpdated = [NSDate dateWithISO8601String:lastUpdatedString];
    }
    
    self.sharing = [self sharingValueForString:attributes[@"sharing"]];
}

- (OZLModelVersionSharing)sharingValueForString:(NSString *)string {
    if ([string isEqualToString:@"descendants"]) {
        return OZLModelVersionSharingWithSubprojects;
    } else if ([string isEqualToString:@"descendants"]) {
        return OZLModelVersionSharingWithProjectHierarchy;
    } else if ([string isEqualToString:@"tree"]) {
        return OZLModelVersionSharingWithProjectTree;
    } else if ([string isEqualToString:@"system"]) {
        return OZLModelVersionSharingWithAll;
    } else {
        return OZLModelVersionSharingNone;
    }
}

- (OZLModelVersionStatus)statusValueForString:(NSString *)string {
    if ([string isEqualToString:@"open"]) {
        return OZLModelVersionStatusOpen;
    } else if ([string isEqualToString:@"locked"]) {
        return OZLModelVersionStatusLocked;
    } else {
        return OZLModelVersionStatusClosed;
    }
}

@end
