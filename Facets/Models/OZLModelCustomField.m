//
//  OZLModelCustomField.m
//  Facets
//
//  Created by Justin Hill on 11/28/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLModelCustomField.h"
#import "Facets-Swift.h"

@interface OZLModelCustomField () {
    id _value;
}

@end

@implementation OZLModelCustomField

+ (NSString *)primaryKey {
    return @"fieldId";
}

+ (NSArray *)ignoredProperties {
    return @[ @"value" ];
}

- (instancetype)initWithAttributeDictionary:(NSDictionary *)attributes {
    if (self = [super init]) {
        [self applyAttributeDictionary:attributes];
    }
    
    return self;
}

- (void)applyAttributeDictionary:(NSDictionary *)attributes {
    self.fieldId = [attributes[@"id"] integerValue];
    self.name = attributes[@"name"];
    
    NSString *valueString = attributes[@"value"];
    
    if (valueString.length > 0) {
        self.value = attributes[@"value"];
    }
}

+ (nonnull NSString *)displayValueForCustomFieldType:(OZLModelCustomFieldType)type attributeId:(NSInteger)attributeId attributeValue:(nonnull NSString *)attributeValue {
    
    static NSNumberFormatter *numberFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
    });
    
    NSAssert([NSThread isMainThread], @"Tried to call a method that uses a number formatter from a non-main thread (it should have been created on the main thread)");
    
    if (type == OZLModelCustomFieldTypeVersion) {
        NSNumber *versionId = [numberFormatter numberFromString:attributeValue];
        
        if (!versionId) {
            NSAssert(NO, @"Wasn't able to parse the version id from the value string");
            
            return attributeValue;
        }
        
        OZLModelVersion *version = [OZLModelVersion objectForPrimaryKey:versionId];
        
        if (version.name) {
            return version.name;
        } else {
            return attributeValue;
        }
        
    } else if (type == OZLModelCustomFieldTypeBoolean) {
        if ([attributeValue isEqualToString:@"0"]) {
            return @"No";
        } else if ([attributeValue isEqualToString:@"1"]) {
            return @"Yes";
        } else {
            return attributeValue;
        }
        
    } else if (type == OZLModelCustomFieldTypeUser) {
        OZLModelUser *user = [OZLModelUser objectForPrimaryKey:attributeValue];
        
        if (user.name) {
            return user.name;
        } else {
            return attributeValue;
        }
    }
    
    return attributeValue;
}

@end
