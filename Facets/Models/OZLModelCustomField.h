//
//  OZLModelCustomField.h
//  Facets
//
//  Created by Justin Hill on 11/28/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <Realm/Realm.h>

@interface OZLModelCustomField : RLMObject

- (instancetype)initWithAttributeDictionary:(NSDictionary *)attributes;

@property (readonly) NSInteger fieldId;
@property (readonly) NSString *name;

@end
