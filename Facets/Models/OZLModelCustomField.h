//
//  OZLModelCustomField.h
//  Facets
//
//  Created by Justin Hill on 11/28/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <Realm/Realm.h>
#import "OZLModelStringContainer.h"

typedef NS_ENUM(NSInteger, OZLModelCustomFieldType) {
    OZLModelCustomFieldTypeInvalid,
    OZLModelCustomFieldTypeBoolean,
    OZLModelCustomFieldTypeDate,
    OZLModelCustomFieldTypeFloat,
    OZLModelCustomFieldTypeInteger,
    OZLModelCustomFieldTypeLink,
    OZLModelCustomFieldTypeList,
    OZLModelCustomFieldTypeLongText,
    OZLModelCustomFieldTypeText,
    OZLModelCustomFieldTypeUser,
    OZLModelCustomFieldTypeVersion
};

RLM_ARRAY_TYPE(OZLModelStringContainer)

@interface OZLModelCustomField : RLMObject

- (instancetype)initWithAttributeDictionary:(NSDictionary *)attributes;

@property NSInteger fieldId;
@property OZLModelCustomFieldType type;
@property (strong) NSString *name;

// Readonly values are ignored by Realm. We don't want to store a value for a custom field,
// so even though semantically it seems weird, functionally, it's correct.
@property (readonly) NSString *value;

@property (strong) RLMArray<OZLModelStringContainer *><OZLModelStringContainer> *options;

@end
