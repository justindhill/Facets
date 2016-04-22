//
//  OZLModelStringContainer.m
//  Facets
//
//  Created by Justin Hill on 12/2/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLModelStringContainer.h"
#import "Facets-Swift.h"

@interface OZLModelStringContainer () <OZLEnumerationFormFieldValue>

@end

@implementation OZLModelStringContainer

+ (nonnull instancetype)containerWithString:(nonnull NSString *)string value:(NSString *)value {
    OZLModelStringContainer *container = [[OZLModelStringContainer alloc] init];
    container.stringValue = string;
    container.value = value;
    
    return container;
}

@end
