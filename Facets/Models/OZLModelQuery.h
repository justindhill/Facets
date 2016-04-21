//
//  OZLModelQuery.h
//  Facets
//
//  Created by Justin Hill on 10/15/15.
//  Copyright © 2015 Lee Zhijie. All rights reserved.
//

@import Foundation;

@interface OZLModelQuery : NSObject

@property NSInteger queryId;
@property (strong) NSString *name;
@property NSInteger projectId;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
