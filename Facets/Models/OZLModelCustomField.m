//
//  OZLModelCustomField.m
//  Facets
//
//  Created by Justin Hill on 11/28/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLModelCustomField.h"

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
    
    _value = attributes[@"value"];
}

@end
