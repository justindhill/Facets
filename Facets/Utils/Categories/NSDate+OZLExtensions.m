//
//  NSDate+OZLExtensions.m
//  Facets
//
//  Created by Justin Hill on 11/14/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "NSDate+OZLExtensions.h"

@implementation NSDate (OZLExtensions)

+ (NSDate *)OZLDateWithServerTimestamp:(id)iso8601 {
    //    Copyright (c) 2008-2014 Sam Soffes, http://soff.es
    //
    //    Permission is hereby granted, free of charge, to any person obtaining
    //    a copy of this software and associated documentation files (the
    //    "Software"), to deal in the Software without restriction, including
    //    without limitation the rights to use, copy, modify, merge, publish,
    //    distribute, sublicense, and/or sell copies of the Software, and to
    //    permit persons to whom the Software is furnished to do so, subject to
    //    the following conditions:
    //
    //    The above copyright notice and this permission notice shall be
    //    included in all copies or substantial portions of the Software.
    //
    //    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    //    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    //    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    //    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    //    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    //    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    //    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    
    // Return nil if nil is given
    if (!iso8601 || [iso8601 isEqual:[NSNull null]]) {
        return nil;
    }
    
    // Parse number
    if ([iso8601 isKindOfClass:[NSNumber class]]) {
        return [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)iso8601 doubleValue]];
        
        // Parse string
    } else if ([iso8601 isKindOfClass:[NSString class]]) {
        const char * str = [iso8601 cStringUsingEncoding:NSUTF8StringEncoding];
        size_t len = strlen(str);
        
        if (len == 0) {
            return nil;
        }
        
        struct tm tm;
        char newStr[25] = "";
        BOOL hasTimezone = NO;
        
        // 2014-03-30T09:13:00Z
        if (len == 20 && str[len - 1] == 'Z') {
            strncpy(newStr, str, len - 1);
            
            // 2014-03-30T09:13:00-07:00
        } else if (len == 25 && str[22] == ':') {
            strncpy(newStr, str, 19);
            hasTimezone = YES;
            
            // 2014-03-30T09:13:00.000Z
        } else if (len == 24 && str[len - 1] == 'Z') {
            strncpy(newStr, str, 19);
            
            // 2014-03-30T09:13:00.000-07:00
        } else if (len == 29 && str[26] == ':') {
            strncpy(newStr, str, 19);
            hasTimezone = YES;
            
            // Poorly formatted timezone
        } else {
            strncpy(newStr, str, len > 24?24:len);
        }
        
        // Timezone
        size_t l = strlen(newStr);
        
        if (hasTimezone) {
            strncpy(newStr + l, str + len - 6, 3);
            strncpy(newStr + l + 3, str + len - 2, 2);
        } else {
            strncpy(newStr + l, "+0000", 5);
        }
        
        // Add null terminator
        newStr[sizeof(newStr) - 1] = 0;
        
        if (strptime(newStr, "%FT%T%z", &tm) == NULL) {
            return nil;
        }
        
        time_t t;
        t = mktime(&tm);
        
        return [NSDate dateWithTimeIntervalSince1970:t];
    }
    
    NSAssert1(NO, @"Failed to parse date: %@", iso8601);
    
    return nil;
}

@end
