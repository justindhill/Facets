//
//  OZLModelStringContainer.m
//  Facets
//
//  Created by Justin Hill on 12/2/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLModelStringContainer.h"

@implementation OZLModelStringContainer

+ (nonnull instancetype)containerWithString:(nonnull NSString *)string {
    OZLModelStringContainer *container = [[OZLModelStringContainer alloc] init];
    container.value = string;
    
    return container;
}

@end
