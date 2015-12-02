//
//  OZLModelCustomField.h
//  Facets
//
//  Created by Justin Hill on 11/28/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <Realm/Realm.h>
#import "OZLModelStringContainer.h"

#warning Custom field support is incomplete! Need to parse the rest of the types.
typedef NS_ENUM(NSInteger, OZLModelCustomFieldType) {
    OZLModelCustomFieldTypeInvalid,
    OZLModelCustomFieldTypeList,
    OZLModelCustomFieldTypeVersion,
    OZLModelCustomFieldTypeBool,
    OZLModelCustomFieldTypeInt
};

RLM_ARRAY_TYPE(OZLModelStringContainer)

@interface OZLModelCustomField : RLMObject

- (instancetype)initWithAttributeDictionary:(NSDictionary *)attributes;

@property NSInteger fieldId;
@property OZLModelCustomFieldType type;
@property (strong) NSString *name;

@property (strong) RLMArray<OZLModelStringContainer *><OZLModelStringContainer> *options;

@end
