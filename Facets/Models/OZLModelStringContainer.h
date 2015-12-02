//
//  OZLModelStringContainer.h
//  Facets
//
//  Created by Justin Hill on 12/2/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <Realm/Realm.h>

@interface OZLModelStringContainer : RLMObject

+ (nonnull instancetype)containerWithString:(nonnull NSString *)string;
@property (nullable, strong) NSString *value;

@end
