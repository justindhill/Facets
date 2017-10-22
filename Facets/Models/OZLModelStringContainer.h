//
//  OZLModelStringContainer.h
//  Facets
//
//  Created by Justin Hill on 12/2/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import Realm;
@protocol OZLEnumerationFormFieldValue;

// Compiler quirk - OZLEnumerationFormFieldValue is declared in Swift.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
@interface OZLModelStringContainer : RLMObject <OZLEnumerationFormFieldValue>
#pragma clang diagnostic pop

+ (nonnull instancetype)containerWithString:(nonnull NSString *)string value:(nonnull NSString *)value;
@property (nullable, strong) NSString *stringValue;
@property (nullable, strong) NSString *value;

@end
