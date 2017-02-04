//
//  OZLModelCustomField.h
//  Facets
//
//  Created by Justin Hill on 11/28/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import Realm;
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

- (nonnull instancetype)initWithAttributeDictionary:(nonnull NSDictionary *)attributes;

@property NSInteger fieldId;
@property OZLModelCustomFieldType type;
@property (nullable, strong) NSString *name;
@property (nullable) id value;
@property (nullable, strong) RLMArray<OZLModelStringContainer *><OZLModelStringContainer> *options;

+ (nonnull NSString *)displayValueForCustomFieldType:(OZLModelCustomFieldType)type attributeId:(NSInteger)attributeId attributeValue:(nonnull NSString *)attributeValue;

@end
