//
//  OZLModelMembership.h
//  Facets
//
//  Created by Justin Hill on 12/24/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OZLModelUser.h"

@interface OZLModelMembership : NSObject

@property (strong) OZLModelUser *user;

- (instancetype)initWithAttributeDictionary:(NSDictionary *)attributes;
- (void)applyAttributeDictionary:(NSDictionary *)attributes;

@end
