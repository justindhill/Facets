//
//  OZLModelMembership.h
//  Facets
//
//  Created by Justin Hill on 12/24/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OZLModelUser.h"

@interface OZLModelMembership : RLMObject

@property NSInteger membershipId;
@property NSInteger projectId;
@property (strong) OZLModelUser *user;

- (instancetype)initWithAttributeDictionary:(NSDictionary *)attributes;
- (void)applyAttributeDictionary:(NSDictionary *)attributes;

@end
