//
//  OZLRedmineHTMLParser.h
//  Facets
//
//  Created by Justin Hill on 12/1/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLModelCustomField.h"

@interface OZLRedmineHTMLParser : NSObject

/**
 *  @brief Parses the custom fields and possible values for them from HTML retrieved from /projects/<pid>/issue/new.
 *         This is necessary because Redmine doesn't allow read-only access to its custom fields via the API.
 */
+ (NSArray<OZLModelCustomField *> *)parseCustomFieldsHTMLString:(NSString *)html error:(NSError **)error;

@end
