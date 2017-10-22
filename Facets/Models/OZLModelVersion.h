//
//  OZLModelVersion.h
//  Facets
//
//  Created by Justin Hill on 12/2/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import Realm;

typedef NS_ENUM(NSInteger, OZLModelVersionSharing) {
    OZLModelVersionSharingNone,
    OZLModelVersionSharingWithSubprojects,
    OZLModelVersionSharingWithProjectHierarchy,
    OZLModelVersionSharingWithProjectTree,
    OZLModelVersionSharingWithAll
};

typedef NS_ENUM(NSInteger, OZLModelVersionStatus) {
    OZLModelVersionStatusOpen,
    OZLModelVersionStatusLocked,
    OZLModelVersionStatusClosed
};

@protocol OZLEnumerationFormFieldValue;

// Compiler quirk - OZLEnumerationFormFieldValue is declared in Swift.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
@interface OZLModelVersion : RLMObject <OZLEnumerationFormFieldValue>
#pragma clang diagnostic pop

- (instancetype)initWithAttributeDictionary:(NSDictionary *)attributes;

@property NSInteger versionId;
@property NSInteger projectId;
@property OZLModelVersionSharing sharing;
@property (strong) NSString *name;
@property (strong) NSString *versionDescription;
@property OZLModelVersionStatus status;
@property (strong) NSDate *dueDate;
@property (strong) NSDate *creationDate;
@property (strong) NSDate *lastUpdated;

@end
