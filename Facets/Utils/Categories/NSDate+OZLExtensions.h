//
//  NSDate+OZLExtensions.h
//  Facets
//
//  Created by Justin Hill on 11/14/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (OZLExtensions)

+ (NSDate *)OZLDateWithServerTimestamp:(id)iso8601;

@end
