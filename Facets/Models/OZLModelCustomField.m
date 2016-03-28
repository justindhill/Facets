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
    NSString *_value;
}

@end

@implementation OZLModelCustomField

+ (NSString *)primaryKey {
    return @"fieldId";
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
        _value = attributes[@"value"];
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
        NSNumber *userId = [numberFormatter numberFromString:attributeValue];
        
        if (!userId) {
            NSAssert(NO, @"Wasn't able to parse the user id from the value string");
            
            return attributeValue;
        }
        
        OZLModelUser *user = [OZLModelUser objectForPrimaryKey:userId];
        
        if (user.name) {
            return user.name;
        } else {
            return attributeValue;
        }
    }
    
    return attributeValue;
}

@end
