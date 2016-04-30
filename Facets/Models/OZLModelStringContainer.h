//
//  OZLModelStringContainer.h
//  Facets
//
//  Created by Justin Hill on 12/2/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import Realm;
@protocol OZLEnumerationFormFieldValue;

@interface OZLModelStringContainer : RLMObject <OZLEnumerationFormFieldValue>

+ (nonnull instancetype)containerWithString:(nonnull NSString *)string value:(nonnull NSString *)value;
@property (nullable, strong) NSString *stringValue;
@property (nullable, strong) NSString *value;

@end
